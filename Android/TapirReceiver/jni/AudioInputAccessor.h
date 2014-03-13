#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
#include <TapirLib.h>

void recorderCallback(SLAndroidSimpleBufferQueueItf bq, void *context);

class AudioInputAccessor
{

public:
	AudioInputAccessor(int frameSize, Tapir::SignalDetector * detector);
	virtual ~AudioInputAccessor();

	void startAudioInput();
	void stopAudioInput();
	// void newInputBuffer(short * inputBuffer, int length);
	void newInputBuffer();


protected:
	// this callback handler is called every time a buffer finishes recording

	int m_frameSize;
	int m_frameByteSize;
	Tapir::SignalDetector * m_detector;

	SLObjectItf m_objEngine;
	SLEngineItf m_engine;

	SLObjectItf m_objRecorder;
	SLRecordItf m_recorder;
	SLAndroidSimpleBufferQueueItf m_bufferQueue;

	int m_curBufferIdx;
	int m_noBuffer;
	short ** m_buffer;

	float * m_floatBuffer;

};
