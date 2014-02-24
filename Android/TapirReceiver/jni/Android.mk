LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := TapirReceiver
LOCAL_SRC_FILES := TapirReceiver.cpp

include $(BUILD_SHARED_LIBRARY)
