APP_ABI := armeabi-v7a
APP_OPTIM := release
APP_PLATFORM := android-14

NDK_TOOLCHAIN_VERSION := clang

#APP_STL := gnustl_static
APP_STL := libc++_static

LOCAL_CPPFLAGS := -std=gnu++11
#LOCAL_CPPFLAGS := -std=c++11 -pthread -frtti -fexceptions
LOCAL_CPPFLAGS += -O2 -verbose



 
