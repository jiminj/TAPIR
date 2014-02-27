#include <jni.h>

#include <assert.h>
#include <jni.h>
#include <string.h>

// for __android_log_print(ANDROID_LOG_INFO, "YourApp", "formatted message");
// #include <android/log.h>

// for native audio
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>

// for native asset manager
#include <sys/types.h>
#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>
#include <android/log.h>

#define LOGV(...) __android_log_print(ANDROID_LOG_VERBOSE, "JNI_DEBUGGING", __VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,   "JNI_DEBUGGING", __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,    "JNI_DEBUGGING", __VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN,    "JNI_DEBUGGING", __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR,   "JNI_DEBUGGING", __VA_ARGS__)

// engine interfaces
static SLObjectItf engineObject = NULL;
static SLEngineItf engineEngine;

// recorder interfaces
static SLObjectItf recorderObject = NULL;
static SLRecordItf recorderRecord;
static SLAndroidSimpleBufferQueueItf recorderBufferQueue;

static short* recorderBuffer[2];
static int currentBuffer;
static int currentBufferIndex;
static unsigned recorderSize = 0;
static SLmilliHertz recorderSR;

static JavaVm *qJavaVM;
static JNIEnv* environment;
static jobject theObject;
static jclass parentClass;
static jmethodID parentCallback;

static int RECORDER_FRAMES = 4410;

void callParentCallback(char* ch){

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
}

// this callback handler is called every time a buffer finishes recording
void bqRecorderCallback(SLAndroidSimpleBufferQueueItf bq, void *context)
{
	//recorderBuffer[currentbuffer] contains (the lastly filled) buffer data
	//do correlation check, decoding, or whatsoever with this array BEFORE enqueueing

    SLresult result;
	result = (*recorderBufferQueue)->Enqueue(recorderBufferQueue, recorderBuffer[currentBuffer],
			RECORDER_FRAMES * sizeof(short));
	assert(SL_RESULT_SUCCESS == result);
	(void)result;

	currentBuffer= (currentBuffer==0?1:0);

	//LOGE("recording...");

    //callParentCallback("recording ");
}





void Java_com_example_tapirreceiver_MainActivity_startTapir( JNIEnv* env,
                                                  jobject thiz )
{
	qJavaVM = android::AndroidRuntime::getJavaVM();
    environment = env;
	theObject = thiz;

	TapirDSP::init();

	callParentCallback("recording initiated");

	currentBuffer = 0;
	currentBufferIndex =0;
	recorderBuffer[0] = (short*)calloc(RECORDER_FRAMES, sizeof(short));
	recorderBuffer[1] = (short*)calloc(RECORDER_FRAMES, sizeof(short));

	SLresult result;


	// create engine
	result = slCreateEngine(&engineObject, 0, NULL, 0, NULL, NULL);
	assert(SL_RESULT_SUCCESS == result);
	(void)result;



	// realize the engine
	result = (*engineObject)->Realize(engineObject, SL_BOOLEAN_FALSE);
	assert(SL_RESULT_SUCCESS == result);
	(void)result;

	// get the engine interface, which is needed in order to create other objects
	result = (*engineObject)->GetInterface(engineObject, SL_IID_ENGINE, &engineEngine);
	assert(SL_RESULT_SUCCESS == result);
	(void)result;

	// configure audio source
	SLDataLocator_IODevice loc_dev = {SL_DATALOCATOR_IODEVICE, SL_IODEVICE_AUDIOINPUT,
			SL_DEFAULTDEVICEID_AUDIOINPUT, NULL};
	SLDataSource audioSrc = {&loc_dev, NULL};

	// configure audio sink
	SLDataLocator_AndroidSimpleBufferQueue loc_bq = {SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE, 2};
	SLDataFormat_PCM format_pcm = {SL_DATAFORMAT_PCM, 1, SL_SAMPLINGRATE_44_1,
		SL_PCMSAMPLEFORMAT_FIXED_16, SL_PCMSAMPLEFORMAT_FIXED_16,
		SL_SPEAKER_FRONT_CENTER, SL_BYTEORDER_LITTLEENDIAN};
	SLDataSink audioSnk = {&loc_bq, &format_pcm};

	// create audio recorder
	// (requires the RECORD_AUDIO permission)
	const SLInterfaceID id[1] = {SL_IID_ANDROIDSIMPLEBUFFERQUEUE};
	const SLboolean req[1] = {SL_BOOLEAN_TRUE};
	result = (*engineEngine)->CreateAudioRecorder(engineEngine, &recorderObject, &audioSrc,
			&audioSnk, 1, id, req);
	if (SL_RESULT_SUCCESS != result) {
		//return JNI_FALSE;
	}

	// realize the audio recorder
	result = (*recorderObject)->Realize(recorderObject, SL_BOOLEAN_FALSE);
	if (SL_RESULT_SUCCESS != result) {
		//return JNI_FALSE;
	}

	// get the record interface
	result = (*recorderObject)->GetInterface(recorderObject, SL_IID_RECORD, &recorderRecord);
	assert(SL_RESULT_SUCCESS == result);
	(void)result;

	// get the buffer queue interface
	result = (*recorderObject)->GetInterface(recorderObject, SL_IID_ANDROIDSIMPLEBUFFERQUEUE,
			&recorderBufferQueue);
	assert(SL_RESULT_SUCCESS == result);
	(void)result;

	// register callback on the buffer queue
	result = (*recorderBufferQueue)->RegisterCallback(recorderBufferQueue, bqRecorderCallback,
			NULL);
	assert(SL_RESULT_SUCCESS == result);
	(void)result;

	// the buffer is not valid for playback yet
	recorderSize = 0;

	// enqueue two empty buffers to be filled by the recorder

	result = (*recorderBufferQueue)->Enqueue(recorderBufferQueue, recorderBuffer[0],
			RECORDER_FRAMES * sizeof(short));
	assert(SL_RESULT_SUCCESS == result);
	(void)result;
	result = (*recorderBufferQueue)->Enqueue(recorderBufferQueue, recorderBuffer[1],
			RECORDER_FRAMES * sizeof(short));
	assert(SL_RESULT_SUCCESS == result);
	(void)result;

	// start recording
	result = (*recorderRecord)->SetRecordState(recorderRecord, SL_RECORDSTATE_RECORDING);
	assert(SL_RESULT_SUCCESS == result);
	(void)result;
}

void Java_com_example_tapir_MainActivity_stopTapir( JNIEnv* env,
                                                  jobject thiz )
{
	SLresult result;
	result = (*recorderRecord)->SetRecordState(recorderRecord, SL_RECORDSTATE_STOPPED);
	if (SL_RESULT_SUCCESS == result) {
		recorderSize = RECORDER_FRAMES * sizeof(short);
		recorderSR = SL_SAMPLINGRATE_16;
	}

	// destroy audio recorder object, and invalidate all associated interfaces
	if (recorderObject != NULL) {
		(*recorderObject)->Destroy(recorderObject);
		recorderObject = NULL;
		recorderRecord = NULL;
		recorderBufferQueue = NULL;
	}

	// destroy engine object, and invalidate all associated interfaces
	if (engineObject != NULL) {
		(*engineObject)->Destroy(engineObject);
		engineObject = NULL;
		engineEngine = NULL;
	}

	free(recorderBuffer[0]);
	free(recorderBuffer[1]);
}
