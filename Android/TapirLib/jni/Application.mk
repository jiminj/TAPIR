APP_ABI := armeabi-v7a
APP_OPTIM := release
APP_PLATFORM := android-14

NDK_TOOLCHAIN_VERSION := 4.8
APP_STL := gnustl_static
APP_CPPFLAGS += -std=c++11 -flax-vector-conversions

#NDK_TOOLCHAIN_VERSION := clang
#APP_CPPFLAGS += -std=gnu++11
#APP_STL := libc++_static


	 


LOCAL_CPPFLAGS := -std=gnu++11 -O2 -verbose



 
