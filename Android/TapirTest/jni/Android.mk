ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
	
	JNI_PATH := $(abspath $(call my-dir))
	LOCAL_PATH := $(abspath $(call my-dir))
	
#load for NE10
 	include $(CLEAR_VARS)
	NE10_LIB_PATH := $(JNI_PATH)/../../Ne10
	LOCAL_MODULE := libNE10
	
	LOCAL_EXPORT_C_INCLUDES := $(NE10_LIB_PATH)/inc
	LOCAL_SRC_FILES := $(NE10_LIB_PATH)/lib/libNE10.a
	include $(PREBUILT_STATIC_LIBRARY)
 	
#load for libTapir	
	include $(CLEAR_VARS)
	TAPIR_LIB_PATH = $(JNI_PATH)/../../libtapir-build
	LOCAL_MODULE := libTapir
	
	LOCAL_EXPORT_C_INCLUDES := $(TAPIR_LIB_PATH)/include
	LOCAL_SRC_FILES := $(TAPIR_LIB_PATH)/lib/libtapir.a
	include $(PREBUILT_STATIC_LIBRARY)
	
	
	include $(CLEAR_VARS)	
	LOCAL_SHARED_LIBRARIES := libandroid_runtime
	LOCAL_STATIC_LIBRARIES := libTapir libNE10 neon_utils cpufeatures 
	LOCAL_ARM_NEON  := true
	
	LOCAL_MODULE    := TapirTest
	
	LOCAL_C_INCLUDES += $(NDK_PATH)/sources/cpufeatures
	LOCAL_SRC_FILES := TapirTest.cpp
	LOCAL_ALLOW_UNDEFINED_SYMBOLS := true
	LOCAL_LDLIBS := -llog
	
	include $(BUILD_SHARED_LIBRARY)

endif