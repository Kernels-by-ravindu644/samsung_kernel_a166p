#!/bin/bash
set -x

echo -e "\n[INFO]: BUILD STARTED..!\n"

export WDIR="$(pwd)"
mkdir -p "${WDIR}/dist"

# Export scripts to the path
export PATH=$PATH:${WDIR}/prebuilts_a166p/scripts

# Init submodules
git submodule init && git submodule update

# Install the requirements for building the kernel when running the script for the first time
if [ ! -f ".requirements" ]; then
    echo -e "\n[INFO]: INSTALLING REQUIREMENTS..!\n"
    {
        sudo apt update
        sudo apt install -y rsync kmod git device-tree-compiler lz4 xz-utils zlib1g-dev openjdk-17-jdk gcc g++ python3 python-is-python3 p7zip-full android-sdk-libsparse-utils
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
    MKBOOTIMG_PATH=${WDIR}/mkbootimg/mkbootimg.py \
    KERNEL_BINARY=Image.gz \
    BOOT_IMAGE_HEADER_VERSION=4 \
    SKIP_VENDOR_BOOT=1 \
    AVB_SIGN_BOOT_IMG=1 \
    AVB_BOOT_PARTITION_SIZE=67108864 \
    AVB_BOOT_KEY=${WDIR}/mkbootimg/tests/data/testkey_rsa2048.pem \
    AVB_BOOT_ALGORITHM=SHA256_RSA2048 \
    AVB_BOOT_PARTITION_NAME=boot  
"

# Build options (extra)
export MKBOOTIMG_EXTRA_ARGS="
    --os_version 13.0.0 \
    --os_patch_level 2025-04-00 \
    --pagesize 4096
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
build_kernel(){
    ( env ${GKI_KERNEL_BUILD_OPTIONS} ./build/build.sh || exit 1 ) && \
        cp "${WDIR}/out/target/product/a16xm/obj/KERNEL_OBJ/dist/boot.img" "${WDIR}/dist"
}

build_tar(){
    echo -e "\n[INFO] Creating an Odin flashable tar..\n"

    cd "${WDIR}/dist"
    tar -cvf "KernelSU-Next-SM-A166P-${BUILD_KERNEL_VERSION}.tar" boot.img vendor_boot.img && rm boot.img vendor_boot.img
    echo -e "\n[INFO] Build Finished..!\n"
    cd "${WDIR}"
}

package_stuffs(){
    echo -e "\n[INFO]: Packaging stuffs...\n"

    cd "${WDIR}/dist"
    zip -r "KernelSU-Next-SM-A166P-${BUILD_KERNEL_VERSION}.zip" "KernelSU-Next-SM-A166P-${BUILD_KERNEL_VERSION}.tar" vendor_dlkm.img && \
    rm "KernelSU-Next-SM-A166P-${BUILD_KERNEL_VERSION}.tar" vendor_dlkm.img

    cd "${WDIR}"
    echo -e "\n[INFO]: Packaging completed.\n"
}

build_kernel || exit 1

build_vendor_boot

# This is only fastbootd compatible, not Odin compatible. So, not adding to the tar.
build_vendor_dlkm

build_tar

package_stuffs
