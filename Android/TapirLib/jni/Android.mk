
ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
	JNI_PATH := $(abspath $(call my-dir))
	LOCAL_PATH := $(JNI_PATH)

#fix it in to installed android sdk path
	ANDROID_SDK_HOME := ~/Development/android/android-sdk-macosx
	LIB_PATH := $(JNI_PATH)/../../../common
	SRC_PATH := $(LIB_PATH)/src
	INCLUDE_PATH := $(LIB_PATH)/include
	NDK_PATH := $(ANDROID_SDK_HOME)/ndk-bundle
	BUILD_PRODUCTS_DIR := $(JNI_PATH)/../obj/local/$(TARGET_ARCH_ABI)
 
#load ne10
 	include $(CLEAR_VARS)
	NE10_LIB_PATH := $(JNI_PATH)/../../Ne10
	LOCAL_MODULE := NE10
	LOCAL_EXPORT_C_INCLUDES := $(NE10_LIB_PATH)/inc
	LOCAL_SRC_FILES := $(NE10_LIB_PATH)/lib/libNE10.a
	include $(PREBUILT_STATIC_LIBRARY)
 
#build for static library
	include $(CLEAR_VARS)
	SRC_PATH := $(LIB_PATH)/src
	INCLUDE_PATH := $(LIB_PATH)/include
	
	LOCAL_C_INCLUDES := \
		sources/cxx-stl/gnu-libstdc++/include \
		$(NDK_PATH)/sources/cpufeatures

	LOCAL_MODULE    := tapir
	LOCAL_STATIC_LIBRARIES  := libNE10 neon_utils cpufeatures
	
	LOCAL_ARM_NEON  := true

	LOCAL_SRC_FILES := TapirLib.cpp \
	$(SRC_PATH)/AutoCorrelator.cpp \
	$(SRC_PATH)/ChannelEstimator.cpp \
	$(SRC_PATH)/Config.cpp \
	$(SRC_PATH)/Decoder.cpp \
	$(SRC_PATH)/Encoder.cpp \
	$(SRC_PATH)/Filter.cpp \
	$(SRC_PATH)/Interleaver.cpp \
	$(SRC_PATH)/Modulator.cpp \
	$(SRC_PATH)/PilotManager.cpp \
	$(SRC_PATH)/SignalAnalyzer.cpp \
	$(SRC_PATH)/SignalDetector.cpp \
	$(SRC_PATH)/SignalGenerator.cpp \
	$(SRC_PATH)/TapirDSP.cpp \
	$(SRC_PATH)/TrellisCode.cpp \
	$(SRC_PATH)/Utilities.cpp \

	include $(BUILD_STATIC_LIBRARY)
	BUILT_RESULT := $(LOCAL_BUILT_MODULE)

#build for dummy shared object

	include $(CLEAR_VARS)
	LOCAL_MODULE := dummy_libtapir
	LOCAL_STATIC_LIBRARIES := tapir NE10
	LOCAL_ALLOW_UNDEFINED_SYMBOLS := true
	LOCAL_ARM_NEON  := true
	
	include $(BUILD_SHARED_LIBRARY)

	include $(NDK_PATH)/sources/android/cpufeatures/Android.mk 

	include $(CLEAR_VARS)

#copy files
	COPY_DEST = $(JNI_PATH)/../../tapir-build

all : 
	mkdir -p $(COPY_DEST)/lib $(COPY_DEST)/include/android
	cp $(BUILT_RESULT) $(COPY_DEST)/lib/
	cp $(INCLUDE_PATH)/*.h $(COPY_DEST)/include/
	#cp $(INCLUDE_PATH)/android/*.h $(COPY_DEST)/include/android

endif

