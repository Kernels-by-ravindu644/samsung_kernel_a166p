########################################################################################################
1. How to Build
   - get Toolchain
      Get the proper toolchain packages from AOSP or CodeSourcery or ETC.
      (Download link : https://opensource.samsung.com/uploadSearch?searchValue=toolchain )

   - Set Build Environment and Export Target Config
      $ cd kernel-5.15
      $ python scripts/gen_build_config.py --kernel-defconfig a16xm_00_defconfig
                                            --kernel-defconfig-overlays "entry_level.config S98901AA1.config S98901AA1_debug.config"
                                            -m user -o ../out/target/product/a16xm/obj/KERNEL_OBJ/build.config

      $ export ARCH=arm64
      $ export CROSS_COMPILE="aarch64-linux-gnu-"
      $ export CROSS_COMPILE_COMPAT="arm-linux-gnueabi-"
      $ export OUT_DIR="../out/target/product/a16xm/obj/KERNEL_OBJ"
      $ export DIST_DIR="../out/target/product/a16xm/obj/KERNEL_OBJ"
      $ export BUILD_CONFIG="../out/target/product/a16xm/obj/KERNEL_OBJ/build.config"

   - To Build
      $ cd ../kernel
      $ ./build/build.sh

2. Output Files
   - Kernel : out/target/product/a16xm/obj/KERNEL_OBJ/kernel-5.15/arch/arm64/boot/Image.gz
   - module : out/target/product/a16xm/obj/KERNEL_OBJ/*.ko

3. How to Clean
   $ make clean
########################################################################################################
