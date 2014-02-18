#include <jni.h>
#include <string.h>
#include <TapirLib.h>

extern "C"
{

jstring Java_com_example_tapirtest_TapirTest_stringFromJNI( JNIEnv* env,
                                                  jobject thiz )
{
#if defined(__arm__)
  #if defined(__ARM_ARCH_7A__)
    #if defined(__ARM_NEON__)
      #define ABI "armeabi-v7a/NEON"
    #else
      #define ABI "armeabi-v7a"
    #endif
  #else
   #define ABI "armeabi"
  #endif
#elif defined(__i386__)
   #define ABI "x86"
#elif defined(__mips__)
   #define ABI "mips"
#else
   #define ABI "unknown"
#endif

// C way
//    return (*env)->NewStringUTF(env, "Hello from JNI !  Compiled with ABI " ABI ".");
// C++ way
	return env->NewStringUTF("Hello from JNI! Compiled with ABI " ABI ".");
//	return;
}


}
