
LIB_PATH := ../../../libTapir
SRC_PATH := $(LIB_PATH)/src
INCLUDE_PATH := $(LIB_PATH)/include

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_C_INCLUDES := sources/cxx-stl/gnu-libstdc++/include/

LOCAL_MODULE    := tapir
LOCAL_INCLUDE_FILES := $(INCLUDE_PATH)
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

include $(CLEAR_VARS)
LOCAL_MODULE := dummy_libtapir

LOCAL_STATIC_LIBRARIES = tapir
include $(BUILD_SHARED_LIBRARY)
