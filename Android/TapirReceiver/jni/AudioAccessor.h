#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
#include <TapirLib.h>


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


void recorderCallback(SLAndroidSimpleBufferQueueItf bq, void *context);

class AudioAccessor
{

public:
	AudioAccessor(int frameSize, Tapir::SignalDetector * detector);
	virtual ~AudioAccessor();

	void startAudioInput();
	void stopAudioInput();
	// void newInputBuffer(short * inputBuffer, int length);
	void newInputBuffer();

protected:
	// this callback handler is called every time a buffer finishes recording

	int m_frameSize;
	Tapir::SignalDetector * m_detector;

	SLObjectItf m_objEngine;
	SLEngineItf m_engine;

	SLObjectItf m_objRecorder;
	SLRecordItf m_recorder;
	SLAndroidSimpleBufferQueueItf m_bufferQueue;

	int m_curBufferIdx;
	int m_noBuffer;
	short ** m_buffer;

};
