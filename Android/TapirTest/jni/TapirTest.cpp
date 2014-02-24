#include <jni.h>

#define DEBUG 1


#if DEBUG
#include <android/log.h>
#define  LOG_TAG    "TAPIRTEST"
#define  LOGUNK(...)  __android_log_print(ANDROID_LOG_UNKNOWN,LOG_TAG,__VA_ARGS__)
#define  LOGDEF(...)  __android_log_print(ANDROID_LOG_DEFAULT,LOG_TAG,__VA_ARGS__)
#define  LOGV(...)  __android_log_print(ANDROID_LOG_VERBOSE,LOG_TAG,__VA_ARGS__)
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGW(...)  __android_log_print(ANDROID_LOG_WARN,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#define  LOGF(...)  __android_log_print(ANDROID_FATAL_ERROR,LOG_TAG,__VA_ARGS__)
#define  LOGS(...)  __android_log_print(ANDROID_SILENT_ERROR,LOG_TAG,__VA_ARGS__)
#endif

#include <string.h>
#include <TapirLib.h>
//#include <Ne10.h>
#include <cmath>

extern "C"
{

//
void test_vstest()
{
    int cnt = 5;
    float * src = new float[cnt];
    float * addDest = new float[cnt];
    float * mulDest = new float[cnt];
    float * divDest = new float[cnt];
    float * mulAccDest = new float[cnt];
//    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src[i] = (float) rand() / RAND_MAX * 5.0f;
    }
    float adder = 0.5;
    float multiplier = 2.0;
    float divider = 2.0;

    TapirDSP::init();

    TapirDSP::vsadd(src, &adder, addDest, cnt);
    TapirDSP::vsmul(src, &multiplier, mulDest, cnt);
    TapirDSP::vsdiv(src, &divider, divDest, cnt);
    TapirDSP::vsmsa(src, &multiplier, &adder, mulAccDest, cnt);
    for(int i=0; i<cnt; ++i)
    {
        LOGD("src[%d] : %f", i, src[i]);
        LOGD("add[%d] : %f", i, addDest[i]);
        LOGD("mul[%d] : %f", i, mulDest[i]);
        LOGD("div[%d] : %f", i, divDest[i]);
        LOGD("multiply and add[%d] : %f", i, mulAccDest[i]);
    }

    delete [] src;
    delete [] addDest;
    delete [] mulDest;
    delete [] divDest;
    delete [] mulAccDest;
}

void test_conv()
{
	int cnt=4;
	float * fsrc = new float[cnt];
	short * ssrc = new short[cnt];
	int * isrc = new int[cnt];

	short * sdest = new short[cnt];
	int * idest = new int[cnt];
	float * fdest1 = new float[cnt];
	float * fdest2 = new float[cnt];

	for(int i=0; i<cnt; ++i)
	{
		fsrc[i] = (float) rand() / RAND_MAX * 5.0f;
		ssrc[i] = (short) (rand() % 10);
		isrc[i] = rand();
	}

    for(int i=0; i<cnt; ++i)
    {
        LOGD("float src[%d] : %f", i, fsrc[i]);
        LOGD("toShort[%d] : %d", i, sdest[i]);
        LOGD("toInt[%d] : %d", i, idest[i]);

        LOGD("short src[%d] : %d", i, ssrc[i]);
		LOGD("toFloat[%d] : %f", i, fdest1[i]);

		LOGD("int src[%d] : %d", i, isrc[i]);
		LOGD("toFloat[%d] : %f", i, fdest2[i]);
//        LOGD("div[%d] : %f", i, divDest[i]);
//        LOGD("multiply and add[%d] : %f", i, mulAccDest[i]);
    }

	delete [] fsrc;
	delete [] ssrc;
	delete [] isrc;

	delete [] sdest;
	delete [] idest;
	delete [] fdest1;
	delete [] fdest2;
}

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

	test_vstest();

//	ne10_addc_float(dest, const_cast<float *>(src), *constScalar, length);
	Tapir::SignalAnalyzer test(20000.f);
//    Tapir::scaleFloatSignal(nullptr, nullptr, 10, 1.0f);
//	test_vsadd();
// C way
//    return (*env)->NewStringUTF(env, "Hello from JNI !  Compiled with ABI " ABI ".");
// C++ way
	return env->NewStringUTF("Hello from JNI! Compiled with ABI " ABI ".====");
//	return;
}



}
