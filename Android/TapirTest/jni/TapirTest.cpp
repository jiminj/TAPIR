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
#include <Ne10.h>
#include <cmath>
#include <time.h>
#include <functional>

extern "C"
{

void testVramp()
{
    int cnt = 1024;
    int loop = 10000;
    float * dest = new float[cnt]();
    
    float init = 0.5f;
    float inc = 1.1f;

    uint64_t stTime, edTime;
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vramp_cpp(&init, &inc, dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    for(int i=cnt-5; i<cnt; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    LOGD("CPP elapsed: %lu", edTime - stTime);
    delete [] dest;
    dest = new float[cnt]();
    
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vramp_neon(&init, &inc, dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    for(int i=cnt-5; i<cnt; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    LOGD("NEON elapsed: %lu", edTime - stTime);
    delete [] dest;
    dest = new float[cnt]();
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vramp(&init, &inc, dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    for(int i=cnt-5; i<cnt; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    LOGD("vDSP elapsed: %lu", edTime - stTime);
    delete [] dest;
    
};

void testMaxv()
{
    int cnt = 2048;
    int loop = 10000;
    
    float * src = new float[cnt];
    float * dest = new float;
    
    clock_t stTime, edTime;
    
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    { src[i] = (float) rand() / RAND_MAX * 5.0f - 5.f; }
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::maxv_cpp(src, dest, cnt);
    }
    edTime = clock();

    LOGD("RESULT : %f", *dest);
    LOGD("elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::maxv_neon(src, dest, cnt);
    }
    edTime = clock();
    LOGD("RESULT : %f", *dest);
    LOGD("elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::maxv(src, dest, cnt);
    }
    edTime = clock();
    LOGD("RESULT : %f", *dest);
    LOGD("elapsed : %lu", edTime - stTime);
    
    delete [] src;
    delete dest;
}

void testMaxmgv()
{
    int cnt = 2048;
    int loop = 10000;
    
    float * src = new float[cnt];
    float * dest = new float;
    
    uint64_t stTime, edTime;
    
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    { src[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f; }
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::maxmgv_cpp(src, dest, cnt);
    }
    edTime = clock();
    
    LOGD("RESULT : %f", *dest);
    LOGD("elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::maxmgv_neon(src, dest, cnt);
    }
    edTime = clock();
    LOGD("RESULT : %f", *dest);
    LOGD("elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::maxmgv(src, dest, cnt);
    }
    edTime = clock();
    LOGD("RESULT : %f", *dest);
    LOGD("elapsed : %lu", edTime - stTime);
    
    delete [] src;
    delete dest;
}

void testVrvrs()
{
    int cnt = 1024;
    int loop = 10000;
    
    float * src = new float[cnt]();
    float * dest = new float[cnt]();
    
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    TapirDSP::copy(src, src+cnt, dest);
    
    uint64_t stTime, edTime;
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vrvrs_cpp(dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    for(int i=cnt-5; i<cnt; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    LOGD("CPP elapsed: %lu", edTime - stTime);
    TapirDSP::copy(src, src+cnt, dest);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vrvrs_neon(dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    for(int i=cnt-5; i<cnt; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    LOGD("NEON elapsed: %lu", edTime - stTime);
    TapirDSP::copy(src, src+cnt, dest);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vrvrs(dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    for(int i=cnt-5; i<cnt; ++i)
    { LOGD("[%d] %f", i, dest[i]);}
    LOGD("NEON elapsed: %lu", edTime - stTime);

    delete [] src;
    delete [] dest;

    
}

void testSvemg()
{
    int cnt = 2048;
    int loop = 10000;
    
    float * src = new float[cnt];
    float * dest = new float;
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    { src[i] = (float) rand() / RAND_MAX * 5.0f; }
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::svemg_cpp(src, dest, cnt);
    }
    edTime = clock();
    LOGD("RESULT : %f", *dest);
    LOGD("Loop : elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::svemg_neon(src, dest, cnt);
    }
    edTime = clock();
    
    LOGD("RESULT : %f", *dest);
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::svemg(src, dest, cnt);
    }
    edTime = clock();
    
    LOGD("RESULT : %f", *dest);
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    delete [] src;
    delete dest;
    
};

void testMaxvi()
{
    int cnt = 2048;
    int loop = 10000;
    
    float * src = new float[cnt];
    float * dest = new float;
    
    uint64_t stTime, edTime;
    TapirDSP::VecLength maxIdx;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    { src[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;}
    
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::maxvi_cpp(src, dest, &maxIdx, cnt);
    }
    edTime = clock();
    
    LOGD("RESULT : %f // %lu", *dest, maxIdx);
    LOGD("elapsed : %lu", edTime - stTime);
    
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
//        TapirDSP::maxv(src, dest, cnt);
//        TapirDSP::maxvi_neon(src, dest, &maxIdx, cnt);
    }
    edTime = clock();
    
    LOGD("RESULT : %f // %lu", *dest, maxIdx);
    LOGD("elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
//        TapirDSP::maxv(src, 1, dest, cnt);
        TapirDSP::maxvi(src, dest, &maxIdx, cnt);
    }
    edTime = clock();
    
    LOGD("RESULT : %f // %lu", *dest, maxIdx);
    LOGD("elapsed : %lu", edTime - stTime);
    
    delete [] src;
    delete dest;
    
};

void testZvmov()
{
    int cnt = 2048;
    int loop = 10000;
    
    TapirDSP::SplitComplex src = {new float[cnt], new float[cnt]};
    TapirDSP::SplitComplex dest = {new float[cnt](), new float[cnt]()};
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src.realp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src.imagp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    for(int i=0; i<5; ++i)
    {
        LOGD("SRC[%d]%f + %f",i, src.realp[i], src.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("SRC[%d]%f + %f",i, src.realp[i], src.imagp[i]);
    }
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvmov_cpp(&src, &dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    delete [] dest.realp;
    delete [] dest.imagp;
    dest.realp = new float[cnt]();
    dest.imagp = new float[cnt]();
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvmov(&src, &dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("VDSP elapsed : %lu", edTime - stTime);
    
    delete [] src.realp;
    delete [] src.imagp;
    delete [] dest.realp;
    delete [] dest.imagp;
};

void testZvmul()
{
    int cnt = 2048;
    int loop = 10000;
    
    TapirDSP::SplitComplex src1 = {new float[cnt], new float[cnt]};
    TapirDSP::SplitComplex src2 = {new float[cnt], new float[cnt]};
    TapirDSP::SplitComplex dest = {new float[cnt](), new float[cnt]()};
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src1.realp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src1.imagp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src2.realp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src2.imagp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvmul_cpp(&src1, &src2, &dest, cnt, 1);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    delete [] dest.realp;
    delete [] dest.imagp;
    dest.realp = new float[cnt]();
    dest.imagp = new float[cnt]();

    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvmul_neon(&src1, &src2, &dest, cnt, 1);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    delete [] dest.realp;
    delete [] dest.imagp;
    dest.realp = new float[cnt]();
    dest.imagp = new float[cnt]();
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvmul(&src1, &src2, &dest, cnt, 1);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("VDSP elapsed : %lu", edTime - stTime);
    
    delete [] src1.realp;
    delete [] src1.imagp;
    delete [] src2.realp;
    delete [] src2.imagp;
    delete [] dest.realp;
    delete [] dest.imagp;
};

void testZvdiv()
{
    int cnt = 2048;
    int loop = 10000;
    
    TapirDSP::SplitComplex src1 = {new float[cnt], new float[cnt]};
    TapirDSP::SplitComplex src2 = {new float[cnt], new float[cnt]};
    TapirDSP::SplitComplex dest = {new float[cnt](), new float[cnt]()};
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src1.realp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src1.imagp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src2.realp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src2.imagp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvdiv_cpp(&src1, &src2, &dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    delete [] dest.realp;
    delete [] dest.imagp;
    dest.realp = new float[cnt]();
    dest.imagp = new float[cnt]();
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvdiv_neon(&src1, &src2, &dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    delete [] dest.realp;
    delete [] dest.imagp;
    dest.realp = new float[cnt]();
    dest.imagp = new float[cnt]();
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvdiv(&src1, &src2, &dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("VDSP elapsed : %lu", edTime - stTime);
    
    delete [] src1.realp;
    delete [] src1.imagp;
    delete [] src2.realp;
    delete [] src2.imagp;
    delete [] dest.realp;
    delete [] dest.imagp;
};

void testZvconj()
{
    int cnt = 2048;
    int loop = 10000;
    
    TapirDSP::SplitComplex src = {new float[cnt], new float[cnt]};
    TapirDSP::SplitComplex dest = {new float[cnt](), new float[cnt]()};
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src.realp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src.imagp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    for(int i=0; i<5; ++i)
    {
        LOGD("SRC[%d]%f + %f",i, src.realp[i], src.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("SRC[%d]%f + %f",i, src.realp[i], src.imagp[i]);
    }
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvconj_cpp(&src, &dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    delete [] dest.realp;
    delete [] dest.imagp;
    dest.realp = new float[cnt]();
    dest.imagp = new float[cnt]();
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvconj_neon(&src, &dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    delete [] dest.realp;
    delete [] dest.imagp;
    dest.realp = new float[cnt]();
    dest.imagp = new float[cnt]();
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvconj(&src, &dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("VDSP elapsed : %lu", edTime - stTime);
    
    delete [] src.realp;
    delete [] src.imagp;
    delete [] dest.realp;
    delete [] dest.imagp;
    
};

void testZvphas()
{
    int cnt = 2048;
    int loop = 10000;
    
    TapirDSP::SplitComplex src = {new float[cnt], new float[cnt]};
    float * dest = new float[cnt]();
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src.realp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src.imagp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    for(int i=0; i<5; ++i)
    {
        LOGD("SRC[%d]%f + %f",i, src.realp[i], src.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("SRC[%d]%f + %f",i, src.realp[i], src.imagp[i]);
    }
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvphas_cpp(&src, dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f",i, dest[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f",i, dest[i]);
    }
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    delete [] dest;
    dest = new float[cnt]();
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvphas_neon(&src, dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f",i, dest[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f",i, dest[i]);
    }

    LOGD("NEON elapsed : %lu", edTime - stTime);

    delete [] dest;
    dest = new float[cnt]();
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::zvphas(&src, dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f",i, dest[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f",i, dest[i]);
    }
    LOGD("VDSP elapsed : %lu", edTime - stTime);
    
    delete [] src.realp;
    delete [] src.imagp;
    delete [] dest;
    
};

void testVvsincosf()
{
    int cnt = 2048;
    int loop = 10000;

    float initState = 0;
//    float initState = -4000.0f * M_PI;
    float inc = 2 * M_PI * 20000.f/44100.f;
    float * src = new float[cnt];
    float * destCos = new float[cnt]();
    float * destSin = new float[cnt]();
    uint64_t stTime, edTime;
    
    TapirDSP::vramp(&initState, &inc, src, cnt);
    for(int i=0; i<5; ++i)
    {
        LOGD("SRC[%d]%f",i, src[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("SRC[%d]%f",i, src[i]);
    }
    

    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vvsincosf_cpp(destSin, destCos, src, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f // %f",i, destSin[i], destCos[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f // %f",i, destSin[i], destCos[i]);
    }
    LOGD("CPP elapsed : %lu", edTime - stTime);

    delete [] destCos; destCos = new float[cnt]();
    delete [] destSin; destSin = new float[cnt]();
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vvsincosf_neon(destSin, destCos, src, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f // %f",i, destSin[i], destCos[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f // %f",i, destSin[i], destCos[i]);
    }
    LOGD("NEON elapsed : %lu", edTime - stTime);
    delete [] destCos; destCos = new float[cnt]();
    delete [] destSin; destSin = new float[cnt]();
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vvsincosf(destSin, destCos, src, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f // %f",i, destSin[i], destCos[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f // %f",i, destSin[i], destCos[i]);
    }
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    delete [] destCos; destCos = new float[cnt]();
    delete [] destSin; destSin = new float[cnt]();
    
    delete [] destCos;
    delete [] destSin;
    delete [] src;
    
};

void testVindex()
{
    int cntSrc = 4096;
    int cntIdx = 10;
    int loop = 10000;
    
    float * src = new float[cntSrc]();
    float * dest = new float[cntIdx]();
    float * idx = new float[cntIdx]();
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cntSrc; ++i)
    {
        src[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    for(int i=0; i<cntIdx; ++i)
    {
        idx[i] = (float)( rand() % cntSrc );
    }
    for(int i=0; i<10; ++i)
    {
        LOGD("SRC[%d] %f", i, src[i]);
    }
    for(int i=0; i<10; ++i)
    {
        LOGD("IDX[%d] %f", i, idx[i]);
    }
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vindex_cpp(src, idx, dest, cntIdx);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    { LOGD("DEST[%d] %f", i, dest[i]); }
    for(int i=cntIdx - 5; i<cntIdx; ++i)
    { LOGD("DEST[%d] %f", i, dest[i]); }
    LOGD("NEON elapsed : %lu", edTime - stTime);
    delete [] dest;
    dest = new float[cntIdx]();

    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vindex(src, idx, dest, cntIdx);
    }
    edTime = clock();
    
    for(int i=0; i<5; ++i)
    { LOGD("DEST[%d] %f", i, dest[i]); }
    for(int i=cntIdx - 5; i<cntIdx; ++i)
    { LOGD("DEST[%d] %f", i, dest[i]); }
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    delete [] src;
    delete [] dest;
    delete [] idx;
    
};

void testMtrans()
{
    int loop = 10000;
    int cnt = 16;
    int m = 8;
    int n = 2;
    float * src = new float[cnt];
    float * dest = new float[cnt]();
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src[i] = (float)i;
    }
    uint64_t stTime, edTime;
    
    stTime = clock();
    for(int i = 0; i< loop; ++i)
    {
        TapirDSP::mtrans_cpp(src, dest, m, n);
    }
    edTime = clock();
    LOGD(" ======== CPP ======== ");
    for(int i=0; i<5; ++i)
    { LOGD("SRC[%d] : %f // DEST[%d] : %f", i, src[i], i, dest[i]); }
    for(int i=cnt - 5; i<cnt; ++i)
    { LOGD("SRC[%d] : %f // DEST[%d] : %f", i, src[i], i, dest[i]); }

    LOGD("CPP elapsed : %lu", edTime - stTime);
    delete [] dest;
    dest = new float[cnt]();
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::mtrans(src, dest, m, n);
    }
    edTime = clock();
    LOGD(" ======== vDSP ======== ");
    for(int i=0; i<5; ++i)
    { LOGD("SRC[%d] : %f // DEST[%d] : %f", i, src[i], i, dest[i]); }
    for(int i=cnt - 5; i<cnt; ++i)
    { LOGD("SRC[%d] : %f // DEST[%d] : %f", i, src[i], i, dest[i]); }

    LOGD("vDSP elapsed : %lu", edTime - stTime);
    delete [] src;
    delete [] dest;
};

void testVgenp()
{
    int loop = 10000;

    int srcCnt = 1024;
    int destCnt = 8192;
    
//    float src[6] = {18.5337, 17.6446, 16.459, 29.8818, 37.7993, 45.7169};
//    float idx[6] = {2.f, 3.f, 7.f, 11.f, 15.f, 17.f};
    float * src = new float[srcCnt];
    float * idx = new float[srcCnt];
    
    srand((unsigned int)time(NULL));
    for(int i=0; i<srcCnt; ++i)
    {
        src[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    idx[0] = (float) (rand() % (destCnt / srcCnt));
    for(int i=1; i<srcCnt; ++ i)
    {
        idx[i] = idx[i-1] + (float)(rand() % (destCnt / srcCnt));
    }

    float * destVdsp = new float[destCnt]();
    float * destCpp = new float[destCnt]();
    uint64_t stTime, edTime;

    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vgenp_cpp(src, idx, destCpp, destCnt, srcCnt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vgenp(src, idx, destVdsp, destCnt, srcCnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    for(int i=0; i<20; ++i)
    {
        LOGD("Result[%d] = %f // %f",i, destVdsp[i], destCpp[i]);
    }

    delete [] destCpp;
    delete [] destVdsp;
};

void testOps()
{
    int cnt = 2048;
    int loop = 10000;
    
    float * src1 = new float[cnt];
    float * src2 = new float[cnt];
    float * destCpp = new float[cnt]();
    float * destNeon = new float[cnt]();
    float * destVdsp = new float[cnt]();
    float srcScal, srcScal2;
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src1[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src2[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    srcScal = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    srcScal2 = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    
    LOGD("======= ADD =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vadd_cpp(src1, src2, destCpp, cnt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vadd_neon(src1, src2, destNeon, cnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vadd(src1, src2, destVdsp, cnt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    
    delete [] destCpp; destCpp = new float[cnt]();
    delete [] destNeon; destNeon = new float[cnt]();
    delete [] destVdsp; destVdsp = new float[cnt]();
    
    LOGD("======= MUL =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vmul_cpp(src1, src2, destCpp, cnt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vmul_neon(src1, src2, destNeon, cnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vmul(src1, src2, destVdsp, cnt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    
    delete [] destCpp; destCpp = new float[cnt]();
    delete [] destNeon; destNeon = new float[cnt]();
    delete [] destVdsp; destVdsp = new float[cnt]();
    
    LOGD("======= SADD =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsadd_cpp(src1, &srcScal, destCpp, cnt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsadd_neon(src1, &srcScal, destNeon, cnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsadd(src1, &srcScal, destVdsp, cnt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    
    delete [] destCpp; destCpp = new float[cnt]();
    delete [] destNeon; destNeon = new float[cnt]();
    delete [] destVdsp; destVdsp = new float[cnt]();
    
    LOGD("======= SMUL =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsmul_cpp(src1, &srcScal, destCpp, cnt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsmul_neon(src1, &srcScal, destNeon, cnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsmul(src1, &srcScal, destVdsp, cnt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    
    delete [] destCpp; destCpp = new float[cnt]();
    delete [] destNeon; destNeon = new float[cnt]();
    delete [] destVdsp; destVdsp = new float[cnt]();
    
    LOGD("======= SDIV =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsdiv_cpp(src1, &srcScal, destCpp, cnt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsdiv_neon(src1, &srcScal, destNeon, cnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsdiv(src1, &srcScal, destVdsp, cnt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    
    delete [] destCpp; destCpp = new float[cnt]();
    delete [] destNeon; destNeon = new float[cnt]();
    delete [] destVdsp; destVdsp = new float[cnt]();
    
    LOGD("======= SMSA =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsmsa_cpp(src1, &srcScal, &srcScal2, destCpp, cnt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsmsa_neon(src1, &srcScal, &srcScal2, destNeon, cnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vsmsa(src1, &srcScal, &srcScal2, destVdsp, cnt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ",i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    
    
    delete [] src1;
    delete [] src2;
    delete [] destCpp;
    delete [] destNeon;
    delete [] destVdsp;
}

void testConvert()
{
    int cnt = 2048;
    int loop = 10000;
    
    float * srcF = new float[cnt];
    short * src16 = new short[cnt];
    int * src32 = new int[cnt];

    short * dest16_cpp = new short[cnt]();
    short * dest16_neon = new short[cnt]();
    short * dest16_vdsp = new short[cnt]();
    
    int * dest32_cpp = new int[cnt]();
    int * dest32_neon = new int[cnt]();
    int * dest32_vdsp = new int[cnt]();
    
    float * destF_cpp = new float[cnt]();
    float * destF_neon = new float[cnt]();
    float * destF_vdsp = new float[cnt]();
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        srcF[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src16[i]= rand() % 1000;
        src32[i] = rand() % 1000;
    }
    
    LOGD("======= Fix16 =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vfix16_cpp(srcF, dest16_cpp, cnt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vfix16_neon(srcF, dest16_neon, cnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vfix16(srcF, dest16_vdsp, cnt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %d \t NEON : %d \t DEST : %d ",i, dest16_cpp[i], dest16_neon[i], dest16_vdsp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d] CPP : %d \t NEON : %d \t DEST : %d ",i, dest16_cpp[i], dest16_neon[i], dest16_vdsp[i]);
    }
    
    
    LOGD("======= Fix32 =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vfix32_cpp(srcF, dest32_cpp, cnt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vfix32_neon(srcF, dest32_neon, cnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vfix32(srcF, dest32_vdsp, cnt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %d \t NEON : %d \t DEST : %d ",i, dest32_cpp[i], dest32_neon[i], dest32_vdsp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d] CPP : %d \t NEON : %d \t DEST : %d ",i, dest32_cpp[i], dest16_neon[i], dest32_vdsp[i]);
    }

    LOGD("======= Flt16 =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vflt16_cpp(src16, destF_cpp, cnt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vflt16_neon(src16, destF_neon, cnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vflt16(src16, destF_vdsp, cnt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t DEST : %f ",i, destF_cpp[i], destF_neon[i], destF_vdsp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t DEST : %f ",i, destF_cpp[i], destF_neon[i], destF_vdsp[i]);
    }

    delete [] destF_cpp; destF_cpp = new float[cnt];
    delete [] destF_neon; destF_neon = new float[cnt];
    delete [] destF_vdsp; destF_vdsp = new float[cnt];
    
    LOGD("======= Flt32 =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vflt32_cpp(src32, destF_cpp, cnt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vflt32_neon(src32, destF_neon, cnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::vflt32(src32, destF_vdsp, cnt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t DEST : %f ",i, destF_cpp[i], destF_neon[i], destF_vdsp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t DEST : %f ",i, destF_cpp[i], destF_neon[i], destF_vdsp[i]);
    }
    
    delete [] srcF; delete [] src16; delete [] src32;
    delete [] dest16_cpp; delete [] dest16_neon; delete [] dest16_vdsp;
    delete [] dest32_cpp; delete [] dest32_neon; delete [] dest32_vdsp;
    delete [] destF_cpp; delete [] destF_neon; delete [] destF_vdsp;

};

void testDotpr()
{
    int cnt = 2048;
    int loop = 10000;
    
    float * src1 = new float[cnt];
    float * src2 = new float[cnt];
    
    float destCpp, destNeon, destVdsp;
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src1[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src2[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    
    LOGD("======= DOTPR =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::dotpr_cpp(src1, src2, &destCpp, cnt);

    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::dotpr_neon(src1, src2, &destNeon, cnt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::dotpr(src1, src2, &destVdsp, cnt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    LOGD("DEST CPP : %f \t NEON : %f \t VDSP : %f ", destCpp, destNeon, destVdsp);
    
    delete [] src1;
    delete [] src2;
};

void testConvolution()
{
    int cntDest = 2048;
    int cntFilt = 256;
    int cntSrc = cntDest + cntFilt - 1;
    int loop = 1;
    
    float * src = new float[cntSrc];
    float * filt = new float[cntFilt];
    float * destCpp = new float[cntDest]();
    float * destNeon = new float[cntDest]();
    float * destVdsp = new float[cntDest]();
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cntSrc; ++i)
    {
        src[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    for(int i=0; i<cntFilt; ++i)
    {
        filt[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    
    LOGD("======= CONV =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::conv_cpp(src, filt, destCpp, cntDest, cntFilt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::conv_neon(src, filt, destNeon, cntDest, cntFilt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::conv(src, filt, destVdsp, cntDest, cntFilt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ", i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    for(int i=cntDest-5; i < cntDest; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ", i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    
    delete [] destCpp; destCpp = new float[cntDest]();
    delete [] destNeon; destNeon = new float[cntDest]();
    delete [] destVdsp; destVdsp = new float[cntDest]();
    
    LOGD("======= CORR =============");
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::corr_cpp(src, filt, destCpp, cntDest, cntFilt);
    }
    edTime = clock();
    LOGD("CPP elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::corr_neon(src, filt, destNeon, cntDest, cntFilt);
    }
    edTime = clock();
    LOGD("NEON elapsed : %lu", edTime - stTime);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::corr(src, filt, destVdsp, cntDest, cntFilt);
    }
    edTime = clock();
    LOGD("vDSP elapsed : %lu", edTime - stTime);
    
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ", i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    for(int i=cntDest-5; i < cntDest; ++i)
    {
        LOGD("DEST[%d] CPP : %f \t NEON : %f \t VDSP : %f ", i, destCpp[i], destNeon[i], destVdsp[i]);
    }
    
    
    
    delete [] src;
    delete [] filt;
    delete [] destCpp;
    delete [] destNeon;
    delete [] destVdsp;
};

void testConvolution2()
{
    int srcLength = 8;
    int trelCodeLength = 7;
    int destLength = 16;
    std::vector<Tapir::TrellisCode> trelCode = Tapir::Config::TRELLIS_ARRAY;
    int encodingRate = static_cast<int>(trelCode.size());
    int inputLength = (srcLength + trelCodeLength - 1);
    
    float * input = new float[inputLength]();
    input[7] = 1; input[8] = 1; input[9] = 1; input[11] = 1;
    float * destOrig = new float[destLength]();
    float * destNew = new float[destLength]();
    float * destNewTrans = new float[destLength]();

//    uint64_t stTime, edTime;
//    srand((unsigned int)time(NULL));
//    for(int i=0; i<inputLength; ++i)
//    {
//        LOGD("SRC[%d] : %f", i, input[i]);
//    }
//    stTime = clock();
//    for(int i=0; i<encodingRate; ++i)
//    {
//        const float * filter = (trelCode.at(i)).getEncodedCode() + trelCodeLength - 1; //set end of the array;
//        TapirDSP::conv(input, 1, filter, -1, destOrig + i, encodingRate, srcLength, trelCodeLength);
//    }
//    edTime = clock();
//    LOGD("elapsed Old : %lu", edTime - stTime);
//    stTime = clock();
//
//    
//    for(int i=0; i<encodingRate; ++i)
//    {
//        const float * filter = (trelCode.at(i)).getEncodedCode();
//        TapirDSP::conv(input, filter, destNew + (i * srcLength), srcLength, trelCodeLength);
//    }
//    TapirDSP::mtrans(destNew, destNewTrans, srcLength, encodingRate);
//    
//    edTime = clock();
//    LOGD("elapsed New: %lu", edTime - stTime);
//
//    for(int i=0; i< destLength; ++i)
//    {
//        LOGD("Result[%d] : %f // %f", i, destOrig[i], destNew[i]);
//    }

    
    delete [] input;
    delete [] destOrig;
    delete [] destNew;
};

void testFft()
{
    int cnt = 128;
    TapirDSP::SplitComplex src = {new float[cnt], new float[cnt]};
    TapirDSP::SplitComplex dest = {new float[cnt], new float[cnt]};
    float realInit = (float)(-cnt/2);
    float realInc = 1.f;
    float imagInit = (float)(cnt/2);
    float imagInc = -1.f;
    
    TapirDSP::vramp(&realInit, &realInc, src.realp, cnt);
    TapirDSP::vramp(&imagInit, &imagInc, src.imagp, cnt);
    Tapir::FFT fft(128);
    fft.transform(&src, &dest, Tapir::FFT::FORWARD);
    
    for(int i=0; i<5; ++i)
    { LOGD("[%d] %f + %f", i, src.realp[i], src.imagp[i]);}
    for(int i=cnt-5; i<cnt; ++i)
    { LOGD("[%d] %f + %f", i, src.realp[i], src.imagp[i]);}

    for(int i=0; i<5; ++i)
    { LOGD("[%d] %f + %f", i, dest.realp[i], dest.imagp[i]);}
    for(int i=cnt-5; i<cnt; ++i)
    { LOGD("[%d] %f + %f", i, dest.realp[i], dest.imagp[i]);}

    delete [] src.realp;
    delete [] src.imagp;
    delete [] dest.realp;
    delete [] dest.imagp;
};

void testZtocCtoz()
{
    
    int cnt = 2048;
    int loop = 1000;
    
    TapirDSP::SplitComplex src = {new float[cnt], new float[cnt]};
    TapirDSP::Complex * compArray = new TapirDSP::Complex[cnt];
    TapirDSP::SplitComplex dest = {new float[cnt](), new float[cnt]()};
    
    uint64_t stTime, edTime;
    srand((unsigned int)time(NULL));
    for(int i=0; i<cnt; ++i)
    {
        src.realp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
        src.imagp[i] = (float) rand() / RAND_MAX * 5.0f - 2.5f;
    }
    for(int i=0; i<5; ++i)
    {
        LOGD("SRC[%d]%f + %f",i, src.realp[i], src.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("SRC[%d]%f + %f",i, src.realp[i], src.imagp[i]);
    }

    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::ztoc_cpp(&src, compArray, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, compArray[i].real, (compArray[i]).imag);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, compArray[i].real, (compArray[i]).imag);
    }
    LOGD("ZTOC - CPP elapsed : %lu", (edTime - stTime) / loop);

    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::ctoz_cpp(compArray, &dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("CTOZ - CPP elapsed : %lu", (edTime - stTime) / loop);
    
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::ztoc(&src, compArray, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, compArray[i].real, (compArray[i]).imag);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, compArray[i].real, (compArray[i]).imag);
    }
    LOGD("ZTOC - vDSP elapsed : %lu", (edTime - stTime) / loop);
    
    stTime = clock();
    for(int i=0; i<loop; ++i)
    {
        TapirDSP::ctoz(compArray, &dest, cnt);
    }
    edTime = clock();
    for(int i=0; i<5; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    for(int i=cnt-5; i<cnt; ++i)
    {
        LOGD("DEST[%d]%f + %f",i, dest.realp[i], dest.imagp[i]);
    }
    LOGD("CTOZ - vDSP elapsed : %lu", (edTime - stTime) / loop);
    
    
    //
    
    //
//    delete [] dest.realp;
//    delete [] dest.imagp;
//    dest.realp = new float[cnt]();
//    dest.imagp = new float[cnt]();
    
};

void testFilter()
{
    int cnt = 2048;
    float * src = new float[cnt];
    float * dest = new float[cnt]();
    float realInit = (float)(-cnt/2);
    float realInc = 1.f;
    
    TapirDSP::vramp(&realInit, &realInc, src, cnt);
    Tapir::Filter * filter = Tapir::FilterCreator::create(4096, Tapir::FilterCreator::EQUIRIPPLE_19k_250);
    filter->process(src, dest, cnt);
    
    for(int i=0; i<5; ++i)
    { LOGD("SRC[%d] %f", i, src[i]);}
    for(int i=cnt-5; i<cnt; ++i)
    { LOGD("SRC[%d] %f", i, src[i]);}

    for(int i=0; i<5; ++i)
    { LOGD("DEST[%d] %f", i, dest[i]);}
    for(int i=cnt-5; i<cnt; ++i)
    { LOGD("DEST[%d] %f", i, dest[i]);}

    
    delete [] dest;
    delete [] src;
};

void signalDetected(float * result)
{
    Tapir::SignalAnalyzer * signalAnalyzer = new Tapir::SignalAnalyzer(Tapir::Config::CARRIER_FREQUENCY_BASE);
    std::string resultStr = (signalAnalyzer->analyze(result));
    std::cout<<resultStr<<std::endl;
};
void testComplete()
{
    Tapir::SignalGenerator * generator = new Tapir::SignalGenerator(Tapir::Config::CARRIER_FREQUENCY_BASE);
    std::string stdInputStr("t");
    int resultLength = generator->calResultLength(stdInputStr.length());
    
    float * encodedAudioData = new float[resultLength]();
    generator->generateSignal(stdInputStr, encodedAudioData, resultLength);
    LOGD("resultLength : %d",resultLength);
    for(int i=0; i<10; ++i)
    { LOGD("[%d] %f", i, encodedAudioData[i]);}
    for(int i=resultLength-10; i<resultLength; ++i)
    { LOGD("[%d] %f", i, encodedAudioData[i]);}


    float * floatBuf = new float[40960]();
    TapirDSP::copy(encodedAudioData, encodedAudioData + resultLength, floatBuf + 3000);

    float maxValue;
    TapirDSP::maxv(floatBuf, &maxValue, resultLength);
    LOGD("MAXVALUE : %f", maxValue);
    
    
//    TapirTest * forCallback = [TapirTest new];
//    auto callback = Tapir::ObjcFuncBridge<void(float *)>(forCallback, @selector(signalDetected:));
    std::function<void(float *)> callback(signalDetected);
    
    Tapir::SignalDetector * detector = new Tapir::SignalDetector(1024, 1.0f, callback);

    for(int i=0; i< 40960; i += 1024)
    {
        float * curBuffer = (floatBuf + i);
        detector->detect(curBuffer);
    }
    
};

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

//  test_vstest();
//    test_complete();

//  ne10_addc_float(dest, const_cast<float *>(src), *constScalar, length);
    Tapir::SignalAnalyzer test(20000.f);
//    Tapir::scaleFloatSignal(nullptr, nullptr, 10, 1.0f);
//  test_vsadd();
// C way
//    return (*env)->NewStringUTF(env, "Hello from JNI !  Compiled with ABI " ABI ".");
// C++ way
    return env->NewStringUTF("Hello from JNI! Compiled with ABI " ABI ".====");
//  return;
}



}
