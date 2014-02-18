ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)

	
	LOCAL_PATH := $(call my-dir)

	LIB_PATH := ../../../libTapir
	SRC_PATH := $(LIB_PATH)/src
	INCLUDE_PATH := $(LIB_PATH)/include
	NDK_PATH := ~/Development/android/android-ndk-r9c
	BUILD_PRODUCTS_DIR := ./obj/local/$(TARGET_ARCH_ABI)
	
	include $(CLEAR_VARS)
	LOCAL_C_INCLUDES := sources/cxx-stl/gnu-libstdc++/include/

	LOCAL_MODULE    := tapir
	LOCAL_INCLUDE_FILES := $(INCLUDE_PATH)
	LOCAL_C_INCLUDES := $(NDK_PATH)/sources/cpufeatures
	LOCAL_STATIC_LIBRARIES  :=  neon_utils cpufeatures
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

	include $(CLEAR_VARS)
	LOCAL_MODULE := dummy_libtapir

	LOCAL_STATIC_LIBRARIES = tapir
	include $(BUILD_SHARED_LIBRARY)

	include $(NDK_PATH)/sources/android/cpufeatures/Android.mk 

	include $(CLEAR_VARS)


endif
#copy files

COPY_DEST = ../libtapir-build

all : 
	mkdir -p $(COPY_DEST)/lib $(COPY_DEST)/include/android
	cp $(BUILT_RESULT) $(COPY_DEST)/lib/
	cp ../../libTapir/include/*.h $(COPY_DEST)/include/
	cp ../../libTapir/include/android/*.h $(COPY_DEST)/include/android


