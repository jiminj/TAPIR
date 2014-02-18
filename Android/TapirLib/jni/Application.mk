APP_ABI := armeabi-v7a
APP_OPTIM := release
APP_PLATFORM := android-14

NDK_TOOLCHAIN_VERSION := clang
LOCAL_CPPFLAGS += -std=gnu++11
LOCAL_CPPFLAGS += -O2

APP_STL := libc++_static