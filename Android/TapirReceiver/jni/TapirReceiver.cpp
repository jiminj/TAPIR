#include <jni.h>

#include <assert.h>
#include <string.h>
//#include <android_runtime/AndroidRuntime.h>
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
#include <functional>
#include <TapirLib.h>

#include "AudioInputAccessor.h"

extern "C"
{

static const int frameSize = 1024;
static Tapir::SignalDetector * signalDetector = nullptr;
static Tapir::SignalAnalyzer * signalAnalyzer = nullptr;
static AudioInputAccessor * aia = nullptr;

static JavaVM *qJavaVM;
static JNIEnv* environment;
static jobject theObject;
static jclass parentClass;
static jmethodID parentCallback;


void callParentCallback(char* ch){
	/*
    int status;
    bool isAttached = false;
    status = qJavaVM->GetEnv((void **) &environment, JNI_VERSION_1_4);
    //not sure for the jni version parameter, try 1_6 when this fails
    if(status<0){
        LOGE("JNI callback is called from a native method");
        status = qJavaVM->AttachCurrentThread(&environment, NULL);
        if(status<0){
            LOGE("failed to attach current thread");
        }
        isAttached = true;
    }
	jstring jstr = environment->NewStringUTF(ch);
    jclass clazz = environment->FindClass( "com/example/tapirreceiver/MainActivity");
    jmethodID messageMe = environment->GetMethodID( clazz, "tc", "(Ljava/lang/String;)Ljava/lang/String;");
    jobject rrr	 = environment->CallObjectMethod( theObject, messageMe, jstr);
    if(isAttached){
        qJavaVM->DetachCurrentThread();
    }
    */

};

void signalDetected(float * result)
{
	LOGD("DETECTED!!!");
    std::string resultStr = (signalAnalyzer->analyze(result));
    const char * resultCStr = resultStr.c_str();
    LOGD("%s", resultCStr);
    signalDetector->clear();

};

void Java_com_example_tapirreceiver_TapirReceiver_initTapir( JNIEnv* env, jobject thiz )
{
	std::function<void(float *)> callback = signalDetected;
	signalDetector = new Tapir::SignalDetector(frameSize, 1.0 ,callback);
	signalAnalyzer = new Tapir::SignalAnalyzer(Tapir::Config::CARRIER_FREQUENCY_BASE);
	aia = new AudioInputAccessor(frameSize, signalDetector);
    // aia = [[LKAudioInputAccessor alloc] initWithFrameSize:frameSize detector:signalDetector];

};
void Java_com_example_tapirreceiver_TapirReceiver_startTapir( JNIEnv* env, jobject thiz )
{

//	qJavaVM = android::AndroidRuntime::getJavaVM();
	env->GetJavaVM(&qJavaVM);

    environment = env;
	theObject = thiz;

//	callParentCallback("recording initiated");
	LOGD("START Tapir");
	aia->startAudioInput();
};

void Java_com_example_tapirreceiver_TapirReceiver_stopTapir( JNIEnv* env, jobject thiz )
{
	LOGD("STOP Tapir");
	aia->stopAudioInput();
};


}
