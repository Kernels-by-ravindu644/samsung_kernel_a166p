#!/bin/bash
set -x

echo -e "\n[INFO]: BUILD STARTED..!\n"

export WDIR="$(pwd)"
mkdir -p "${WDIR}/dist"

# Init submodules
git submodule init && git submodule update

# Install the requirements for building the kernel when running the script for the first time
if [ ! -f ".requirements" ]; then
    echo -e "\n[INFO]: INSTALLING REQUIREMENTS..!\n"
    {
        sudo apt update
        sudo apt install -y \
            git device-tree-compiler lz4 xz-utils zlib1g-dev openjdk-17-jdk gcc g++ python3 python-is-python3 p7zip-full android-sdk-libsparse-utils erofs-utils \
            default-jdk git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses-dev libx11-dev libreadline-dev libgl1 libgl1-mesa-dev \
            python3 make sudo gcc g++ bc grep tofrodos python3-markdown libxml2-utils xsltproc zlib1g-dev python-is-python3 libc6-dev libtinfo6 \
            make repo cpio kmod openssl libelf-dev pahole libssl-dev libarchive-tools zstd --fix-missing

        curl -LO http://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb
        sudo dpkg -i libtinfo5_6.3-2ubuntu0.1_amd64.deb && rm libtinfo5_6.3-2ubuntu0.1_amd64.deb
    } && touch .requirements
fi


# Init Samsung's ndk
if [[ ! -d "${WDIR}/kernel/prebuilts" || ! -d "${WDIR}/prebuilts" ]]; then
    echo -e "\n[INFO] Cloning Samsung's NDK...\n"
    curl -LO "https://github.com/ravindu644/android_kernel_a166p/releases/download/toolchain/toolchain.tar.gz"
    tar -xf toolchain.tar.gz && rm toolchain.tar.gz
    cd "${WDIR}"
fi

# Localversion
if [ -z "$BUILD_KERNEL_VERSION" ]; then
    export BUILD_KERNEL_VERSION="dev"
fi

echo -e "CONFIG_LOCALVERSION_AUTO=n\nCONFIG_LOCALVERSION=\"-ravindu644-${BUILD_KERNEL_VERSION}\"\n" > "${WDIR}/custom_defconfigs/version_defconfig"

# CHANGED DIR
cd "${WDIR}/kernel-5.15"

# Cook the build config
python scripts/gen_build_config.py \
  --kernel-defconfig a16xm_00_defconfig \
  --kernel-defconfig-overlays "entry_level.config S98901AA1.config S98901AA1_debug.config" \
  -m user \
  -o ../out/target/product/a16xm/obj/KERNEL_OBJ/build.config

export KBUILD_BUILD_USER="@ravindu644"

# OEM's variables from their build_kernel.sh
export ARCH=arm64
export PLATFORM_VERSION=13
export CROSS_COMPILE="aarch64-linux-gnu-"
export CROSS_COMPILE_COMPAT="arm-linux-gnueabi-"
export OUT_DIR="../out/target/product/a16xm/obj/KERNEL_OBJ"
export DIST_DIR="../out/target/product/a16xm/obj/KERNEL_OBJ"
export BUILD_CONFIG="../out/target/product/a16xm/obj/KERNEL_OBJ/build.config"
export MERGE_CONFIG="${WDIR}/kernel-5.15/scripts/kconfig/merge_config.sh"

# Build options
export GKI_KERNEL_BUILD_OPTIONS="
SKIP_MRPROPER=1 \
KMI_SYMBOL_LIST_STRICT_MODE=0 \
ABI_DEFINITION= \
BUILD_BOOT_IMG=1 \
MKBOOTIMG_PATH=${WDIR}/external_prebuilts/mkbootimg/mkbootimg.py \
KERNEL_BINARY=Image.gz \
BOOT_IMAGE_HEADER_VERSION=4 \
SKIP_VENDOR_BOOT=1 \
AVB_SIGN_BOOT_IMG=1 \
AVB_BOOT_PARTITION_SIZE=67108864 \
AVB_BOOT_KEY=${WDIR}/external_prebuilts/sign_keys/testkey_rsa2048.pem \
AVB_BOOT_ALGORITHM=SHA256_RSA2048 \
AVB_BOOT_PARTITION_NAME=boot \
"

# Build options (extra)
export MKBOOTIMG_EXTRA_ARGS="
    --os_version 13.0.0 \
    --os_patch_level 2025-01-00 \
    --pagesize 4096 \
"

# Run menuconfig only if you want to.
# It's better to use MAKE_MENUCONFIG=0 when everything is already properly enabled, disabled, or configured.
export MAKE_MENUCONFIG=0

if [ "$MAKE_MENUCONFIG" = "1" ]; then
    export HERMETIC_TOOLCHAIN=0
fi

# CHANGED DIR
cd "${WDIR}/kernel"

# Main cooking progress & copy the built kernel to "dist"
( env ${GKI_KERNEL_BUILD_OPTIONS} ./build/build.sh || exit 1 ) && \

    # Copy the kernel image and boot image to the dist directory
    cp "${WDIR}/out/target/product/a16xm/obj/KERNEL_OBJ/kernel-5.15/arch/arm64/boot/Image"* "${WDIR}/dist" && \
    cp "${WDIR}/out/target/product/a16xm/obj/KERNEL_OBJ/dist/boot.img" "${WDIR}/dist"
