#!/bin/bash

echo -e "\n[INFO]: BUILD STARTED..!\n"

export WDIR="$(pwd)"
mkdir -p "${WDIR}/dist"

# Init submodules
git submodule init && git submodule update

# Install the requirements for building the kernel when running the script for the first time
if [ ! -f ".requirements" ]; then
    sudo apt update && sudo apt install -y git device-tree-compiler lz4 xz-utils zlib1g-dev openjdk-17-jdk gcc g++ python3 python-is-python3 p7zip-full android-sdk-libsparse-utils erofs-utils \
        default-jdk git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses-dev libx11-dev libreadline-dev libgl1 libgl1-mesa-dev \
        python3 make sudo gcc g++ bc grep tofrodos python3-markdown libxml2-utils xsltproc zlib1g-dev python-is-python3 libc6-dev libtinfo6 \
        make repo cpio kmod openssl libelf-dev pahole libssl-dev libarchive-tools zstd --fix-missing && wget http://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb && sudo dpkg -i libtinfo5_6.3-2ubuntu0.1_amd64.deb && touch .requirements
fi

# Init Samsung's ndk
if [[ ! -d "${WDIR}/kernel/prebuilts" || ! -d "${WDIR}/prebuilts" ]]; then
    echo -e "\n[INFO] Cloning Samsung's NDK...\n"
    curl -LO "https://github.com/ravindu644/android_kernel_a166p/releases/download/toolchain/toolchain.tar.gz"
    tar -xf toolchain.tar.gz && rm toolchain.tar.gz
    cd "${WDIR}"
fi

# CHANGED DIR
cd "${WDIR}/kernel-5.15"

# Cook a build config
python scripts/gen_build_config.py --kernel-defconfig a16xm_00_defconfig --kernel-defconfig-overlays "entry_level.config S98901AA1.config S98901AA1_debug.config" -m user -o ../out/target/product/a16xm/obj/KERNEL_OBJ/build.config

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
"

# Run menuconfig only if you want to.
# It's better to use MAKE_MENUCONFIG=0 when everything is already properly enabled, disabled, or configured.
export MAKE_MENUCONFIG=1

if [ "$MAKE_MENUCONFIG" = "1" ]; then
    export HERMETIC_TOOLCHAIN=0
fi

# CHANGED DIR
cd "${WDIR}/kernel"

# Main cooking progress & copy the built kernel to "dist"
( env ${GKI_KERNEL_BUILD_OPTIONS} ./build/build.sh || exit 1 ) && \
  cp "${WDIR}/out/target/product/a16xm/obj/KERNEL_OBJ/kernel-5.15/arch/arm64/boot/Image"* "${WDIR}/dist"
   