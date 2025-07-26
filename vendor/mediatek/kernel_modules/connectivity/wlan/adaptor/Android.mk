LOCAL_PATH := $(call my-dir)
MAIN_PATH := $(LOCAL_PATH)
CONNAC_VER := 1_0
WIFI_NAME := wmt_chrdev_wifi
include $(MAIN_PATH)/build_cdev_wifi.mk
include $(MAIN_PATH)/wlan_page_pool/Android.mk
