include $(CLEAR_VARS)

LOCAL_MODULE := wmt_chrdev_wifi.ko
LOCAL_PROPRIETARY_MODULE := true
LOCAL_MODULE_OWNER := mtk
LOCAL_INIT_RC := init.wlan_drv.rc
LOCAL_REQUIRED_MODULES := wmt_drv.ko

WIFI_ADAPTOR_OPTS := CONNAC_VER=1_0 MODULE_NAME=wmt_chrdev_wifi
include $(MTK_KERNEL_MODULE)
$(linked_module): OPTS += $(WIFI_ADAPTOR_OPTS)
