#
# Copyright (C) 2015 MediaTek Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#

ifndef TOP
    TOP := $(srctree)/..
endif

# Connectivity combo driver
ifneq ($(KERNELRELEASE),)

    # Common include paths and flags
    subdir-ccflags-y += -I$(srctree)/
    subdir-ccflags-y += -I$(srctree)/drivers/misc/mediatek/base/power/include
    subdir-ccflags-y += -I$(srctree)/drivers/misc/mediatek/clkbuf/src
    subdir-ccflags-y += -Werror -I$(srctree)/drivers/misc/mediatek/include/mt-plat
    subdir-ccflags-y += -I$(srctree)/drivers/mmc/core
    subdir-ccflags-y += -I$(srctree)/drivers/misc/mediatek/eccci/
    subdir-ccflags-y += -I$(srctree)/drivers/clk/mediatek/
    subdir-ccflags-y += -I$(srctree)/drivers/pinctrl/mediatek/
    subdir-ccflags-y += -I$(srctree)/drivers/misc/mediatek/power_throttling/
    subdir-ccflags-y += -I$(srctree)/drivers/misc/mediatek/connectivity/common

    # --- CORE DEPENDENCIES ---
    obj-m += connadp.o

    connadp-objs += common/connectivity_build_in_adapter.o
    connadp-objs += common/wmt_build_in_adapter.o
    connadp-objs += power_throttling/adapter.o
    connadp-objs += power_throttling/core.o

    ifeq ($(CONFIG_CONN_PWR_DEBUG),y)
        connadp-objs += power_throttling/test.o
    endif

    # ConnFem driver
    PATH_TO_CONNFEM_DRV := vendor/mediatek/kernel_modules/connectivity/connfem
    $(shell ln -s -f $(TOP)/$(PATH_TO_CONNFEM_DRV) $(srctree)/$(src)/connfem_ext)

    obj-m += connfem_ext/

    # WMT driver (Common dependency)
    PATH_TO_WMT_DRV := vendor/mediatek/kernel_modules/connectivity/common
    $(shell ln -s -f $(TOP)/$(PATH_TO_WMT_DRV) $(srctree)/$(src)/wmt_drv_ext)

    obj-m += wmt_drv_ext/

    # --- Mediatek WLAN Driver ---
    ifeq ($(CONFIG_WLAN_DRV_MODULE),y)

        PATH_TO_WLAN_CHR_DRV := vendor/mediatek/kernel_modules/connectivity/wlan/adaptor
        PATH_TO_WLAN_DRV := vendor/mediatek/kernel_modules/connectivity/wlan/core/gen4m

        WLAN_HIF_TYPE := axi

        $(warning Building WLAN driver modules)
        $(shell ln -s -f $(TOP)/$(PATH_TO_WLAN_CHR_DRV) $(srctree)/$(src)/wmt_chrdev_wifi_ext)
        $(shell ln -s -f $(TOP)/$(PATH_TO_WLAN_DRV) $(srctree)/$(src)/wlan_drv_gen4m_ext)

        # Essential WLAN include paths
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/os/linux/include
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/os/none/include
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/os
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/os/linux/hif/$(WLAN_HIF_TYPE)/include
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/os/linux/hif/common/include
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/wlan_service/include
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/include
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/include/nic
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/include/mgmt
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/include/chips
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/include/wpa_supp
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/wlan_service/service/include
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/wlan_service/glue/osal/include
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_WLAN_DRV)/wlan_service/glue/hal/include
        subdir-ccflags-y += -I$(TOP)/vendor/mediatek/kernel_modules/connectivity/wlan/core/gen4m_ext/include
        subdir-ccflags-y += -I$(TOP)/vendor/mediatek/kernel_modules/connectivity/wlan/core/gen4m_ext/include/mgmt
        subdir-ccflags-y += -Wno-unused-variable -Wno-unused-but-set-variable

        # Build wmt_chrdev_wifi.ko by pointing to the correct subdirectory
        # and exporting the variables its internal Kbuild needs.
        export CONNAC_VER=1_0

        obj-m += wmt_chrdev_wifi_ext/build/connac1x/

        # Build wlan_drv_gen4m_6835.ko
        export CONFIG_MTK_COMBO_WIFI_HIF=axi
        export MTK_COMBO_CHIP=SOC2_1X1
        export WLAN_CHIP_ID=6835
        export MTK_ANDROID_WMT=y
        export MODULE_NAME=wlan_drv_gen4m_6835

        obj-m += wlan_drv_gen4m_ext/
    endif

    # --- Mediatek Bluetooth Driver ---
    ifeq ($(CONFIG_MTK_BT_DRV_EXTERNAL),y)

        PATH_TO_BT_DRV := vendor/mediatek/kernel_modules/connectivity/bt

        $(warning Building external BT module from $(PATH_TO_BT_DRV))
        $(shell ln -s -f $(TOP)/$(PATH_TO_BT_DRV) $(srctree)/$(src)/bt_drv_ext)

        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_BT_DRV)/linux_v2/include
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_BT_DRV)/mt66xx/include/btif

        export BT_PLATFORM=connac1x
        export MTK_PLATFORM=mt6835

        obj-m += bt_drv_ext/mt66xx/wmt/
    endif

    # --- Mediatek GPS Driver ---
    ifeq ($(CONFIG_MTK_GPS_DRV_EXTERNAL),y)

        export AUTOCONF_H=$(O)/include/generated/autoconf.h

        PATH_TO_GPS_DRV := vendor/mediatek/kernel_modules/connectivity/gps

        $(warning Building only the necessary GPS modules)
        $(shell ln -s -f $(TOP)/$(PATH_TO_GPS_DRV) $(srctree)/$(src)/gps_drv_ext)

        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_GPS_DRV)/include

        obj-m += gps_drv_ext/gps_stp/
        obj-m += gps_drv_ext/gps_pwr/
    endif

    # --- Mediatek FM Radio Driver ---
    ifeq ($(CONFIG_MTK_FM_DRV_EXTERNAL),y)

        PATH_TO_FM_DRV := vendor/mediatek/kernel_modules/connectivity/fmradio

        $(warning Building external FM Radio module from $(PATH_TO_FM_DRV))
        $(shell ln -s -f $(TOP)/$(PATH_TO_FM_DRV) $(srctree)/$(src)/fm_drv_ext)

        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_FM_DRV)/include
        subdir-ccflags-y += -I$(TOP)/$(PATH_TO_FM_DRV)/Build/mt6631_6635/include

        export CFG_FM_PLAT=mt6631_6635
        export CFG_BUILD_CONNAC2=false

        obj-m += fm_drv_ext/Build/mt6631_6635/
    endif

else
    # Called directly from command line
    KERNELDIR ?= /lib/modules/$(shell uname -r)/build
    PWD := $(shell pwd)
default:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
endif
