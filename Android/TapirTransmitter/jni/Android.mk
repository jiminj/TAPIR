ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
	
	JNI_PATH := $(abspath $(call my-dir))
	LOCAL_PATH := $(abspath $(call my-dir))
	
#load for NE10
	include $(CLEAR_VARS)
	NE10_LIB_PATH := $(JNI_PATH)/../../../extern/Ne10
	LOCAL_MODULE := NE10
	LOCAL_EXPORT_C_INCLUDES := $(NE10_LIB_PATH)/inc
	LOCAL_SRC_FILES := $(NE10_LIB_PATH)/build/modules/libNE10.a
	include $(PREBUILT_STATIC_LIBRARY)
 	
#load for libTapir	
	include $(CLEAR_VARS)
	TAPIR_LIB_PATH = $(JNI_PATH)/../../tapir-build
	LOCAL_MODULE := Tapir
	
	LOCAL_EXPORT_C_INCLUDES := $(TAPIR_LIB_PATH)/include
	LOCAL_SRC_FILES := $(TAPIR_LIB_PATH)/lib/libtapir.a
	include $(PREBUILT_STATIC_LIBRARY)
	
	
	include $(CLEAR_VARS)	
	
	LOCAL_STATIC_LIBRARIES := Tapir NE10 neon_utils cpufeatures 
	LOCAL_ARM_NEON  := true
	
	LOCAL_MODULE    := TapirTransmitter
	LOCAL_SRC_FILES := TapirTransmitter.cpp
	
	LOCAL_C_INCLUDES += $(NDK_PATH)/sources/cpufeatures
	LOCAL_ALLOW_UNDEFINED_SYMBOLS := true
	LOCAL_LDLIBS += -llog
	
	# for native audio
	LOCAL_LDLIBS    += -lOpenSLES
	# for native asset manager
	LOCAL_LDLIBS    += -landroid
	include $(BUILD_SHARED_LIBRARY)

endif
