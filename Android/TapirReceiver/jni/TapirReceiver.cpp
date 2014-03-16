#include <jni.h>

#include <assert.h>
#include <string.h>
#define DEBUG 1

#if DEBUG
#include <android/log.h>
#define  LOG_TAG    "TAPIR_RECEIVER"
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

// for native audio
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>

// for native asset manager
#include <sys/types.h>
#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>
#include <tr1/functional>
#include <TapirLib.h>

#include "AudioInputAccessor.h"

extern "C"
{
static JavaVM *gJavaVM;
static jmethodID gCallbackId;
static jobject gObjTapirInterface;

Tapir::SignalDetector * signalDetector = nullptr;
Tapir::SignalAnalyzer * signalAnalyzer = nullptr;
AudioInputAccessor * aia = nullptr;

const int frameSize = 1024;
const char * kInterfacePath = "com/example/tapirreceiver/TapirReceiver";
const char * kCallbackMethodName = "callBack";

void callParentCallback(std::string& str){
    bool isAttached = false;
    JNIEnv* env;

    int status = gJavaVM->GetEnv((void **) &env, JNI_VERSION_1_6);
    if(status<0)
    {
        LOGD("JNI callback is called from a native method");
        status = gJavaVM->AttachCurrentThread(&env, NULL);
        if(status<0){
            LOGD("failed to attach current thread");
        }
        isAttached = true;
    }
	jstring jResultString = env->NewStringUTF(str.c_str());
	env->CallVoidMethod(gObjTapirInterface, gCallbackId, jResultString);
    if(isAttached) {gJavaVM->DetachCurrentThread(); }
};

void signalDetected(float * result)
{
	LOGD("DETECTED!!!");
    std::string resultStr = (signalAnalyzer->analyze(result));
    callParentCallback(resultStr);
    signalDetector->clear();
};

void Java_com_example_tapirreceiver_TapirReceiver_initTapir( JNIEnv* env, jobject thiz )
{

	env->GetJavaVM(&gJavaVM);
	gObjTapirInterface = env->NewGlobalRef(thiz);
	jclass clazz = env->GetObjectClass(gObjTapirInterface);
	gCallbackId = env->GetMethodID(clazz, kCallbackMethodName, "(Ljava/lang/String;)V" );

	signalDetector = new Tapir::SignalDetector(frameSize, 1.0 ,std::function<void(float *)>(signalDetected));
	signalAnalyzer = new Tapir::SignalAnalyzer(Tapir::Config::CARRIER_FREQUENCY_BASE);
	aia = new AudioInputAccessor(frameSize, signalDetector);

};
void Java_com_example_tapirreceiver_TapirReceiver_startTapir( JNIEnv* env, jobject thiz )
{
	LOGD("START Tapir");
	aia->startAudioInput();
};

void Java_com_example_tapirreceiver_TapirReceiver_stopTapir( JNIEnv* env, jobject thiz )
{
	LOGD("STOP Tapir");
	aia->stopAudioInput();
};

void Java_com_example_tapirreceiver_TapirReceiver_destroyTapir( JNIEnv* env, jobject thiz )
{
	LOGD("Destroy TAPIR");
	delete aia;
	delete signalDetector;
	delete signalAnalyzer;

};

}
