//
//  Recorder.m
//  ParrotAim
//
//  Created by Seunghun Kim on 10. 5. 4..
//  Copyright 2010 카이스트. All rights reserved.
//

#import "Recorder.h"


@implementation Recorder

@synthesize aqData;

static void HandleInputBuffer (
							   void                                 *aqData,
							   AudioQueueRef                        inAQ,
							   AudioQueueBufferRef                  inBuffer,
							   const AudioTimeStamp                 *inStartTime,
							   UInt32                               inNumPackets,
							   const AudioStreamPacketDescription   *inPacketDesc
							   ) {
   	
    AQRecorderState *pAqData = aqData;


    int *values = (int *) (inBuffer->mAudioData);

    
    Recorder *t = (Recorder *)pAqData->recorder;
    for(int i = 0; i < inNumPackets; ++i){
            
        [t addFilter:values[i]];
              
    }
 
    pAqData->mCurrentPacket += inNumPackets;                     // 4
        
    if (pAqData->mIsRunning == 0)                                         // 5
		return;
    
    AudioQueueEnqueueBuffer (pAqData->mQueue, inBuffer, 0, NULL );
	
}





-(void)start{
	aqData.rec=NO;// 1
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documentsDirectory = [[paths objectAtIndex:0] retain];
	aqData.rec = FALSE;
	aqData.mDataFormat.mFormatID         = kAudioFormatLinearPCM; // 2
	aqData.mDataFormat.mSampleRate       = 44100.0;               // 3
	aqData.mDataFormat.mChannelsPerFrame = 1;                     // 4
	aqData.mDataFormat.mBitsPerChannel   = 32;                    // 5
	aqData.mDataFormat.mBytesPerPacket   = 4;                       // 6
	aqData.mDataFormat.mBytesPerFrame = 4;
	//aqData.mDataFormat.mChannelsPerFrame * sizeof (SInt16);
	aqData.mDataFormat.mFramesPerPacket  = 1;                     // 7
	aqData.recorder = self;

    
	aqData.mDataFormat.mFormatFlags =                             // 9
    // kLinearPCMFormatFlagIsBigEndian
    kLinearPCMFormatFlagIsSignedInteger
    | kLinearPCMFormatFlagIsPacked;
	
	OSStatus er =  AudioQueueNewInput (                              // 1
                                       &aqData.mDataFormat,                          // 2
                                       HandleInputBuffer,                            // 3
                                       &aqData,                                      // 4
                                       NULL,                                         // 5
                                       kCFRunLoopCommonModes,                        // 6
                                       0,                                            // 7
                                       &aqData.mQueue                                // 8
                                       );
	
	
	UInt32 dataFormatSize = sizeof (aqData.mDataFormat);       // 1
	
	er = AudioQueueGetProperty (                                    // 2
                                aqData.mQueue,                                         // 3
                                kAudioQueueProperty_StreamDescription,                 // 4
                                // in Mac OS X, instead use
                                //    kAudioConverterCurrentInputStreamDescription
                                &aqData.mDataFormat,                                   // 5
                                &dataFormatSize                                        // 6
                                );
    
	
	DeriveBufferSize (                               // 1
                      
                      aqData.mQueue,                               // 2
                      
                      aqData.mDataFormat,                          // 3
                      
                      0.01,                                         // 4
                      
                      &aqData.bufferByteSize                      // 5
                      
                      );
    
	for (int i = 0; i < kNumberBuffers; ++i) {           // 1
		AudioQueueAllocateBuffer (                       // 2
								  aqData.mQueue,                               // 3
								  aqData.bufferByteSize,                              // 4
								  &aqData.mBuffers[i]                          // 5
								  );
		
		AudioQueueEnqueueBuffer (                        // 6
								 aqData.mQueue,                               // 7
								 aqData.mBuffers[i],                          // 8
								 0,                                           // 9
								 NULL                                         // 10
								 );
	}
	
	UInt32 val = 1;
	er = AudioQueueSetProperty(aqData.mQueue, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32));
	
	
	aqData.mCurrentPacket = 0;                           // 1
	aqData.mIsRunning = true;                            // 2
	OSStatus st;
    

    
	st = AudioQueueStart (                                    // 3
                          aqData.mQueue,                                   // 4
                          NULL                                             // 5
                          );
    NSLog(@"Audio Start");
    
    decoder = [[strDecoder alloc]init];
    [decoder setCheck];
    
    threshold = 0.08;

}



-(void)stop{
	aqData.rec = FALSE;
	AudioQueueStop (                                     // 6
					aqData.mQueue,                                   // 7
					true                                             // 8
					);
	
	aqData.mIsRunning = false;                           // 9
	
	AudioQueueDispose (                                 // 1
					   aqData.mQueue,                                  // 2
					   true                                            // 3
					   );
	
	AudioFileClose (aqData.mAudioFile);                 // 4
    
    NSLog(@"Audio stop");
    
    [decoder release];
}
-(BOOL)isRec{
	return aqData.rec;
}
-(NSString*)getPath{
	return path;
}

void DeriveBufferSize (
                      
                      AudioQueueRef                audioQueue,                  // 1
                      
                      AudioStreamBasicDescription  ASBDescription,             // 2
                      
                      Float64                      seconds,                     // 3
                      
                      UInt32                       *outBufferSize               // 4
                      
                      ) {
    
    static const int maxBufferSize = 0x50000;                 // 5
    
    
    
    int maxPacketSize = ASBDescription.mBytesPerPacket;       // 6
    
    if (maxPacketSize == 0) {                                 // 7
        
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        
        AudioQueueGetProperty (
                               
                               audioQueue,
                               
                               kAudioConverterPropertyMaximumOutputPacketSize,
                               
                               &maxPacketSize,
                               
                               &maxVBRPacketSize
                               
                               );
        
    }
    
    
    
    Float64 numBytesForTime =    ASBDescription.mSampleRate * maxPacketSize * seconds; // 8
    
    *outBufferSize = (UInt32)(numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize);                     // 9
    
}

- (float) averagePower
{
    AudioQueueLevelMeterState state[1];
    UInt32  statesize = sizeof(state);
    OSStatus status;
    status = AudioQueueGetProperty(aqData.mQueue, kAudioQueueProperty_CurrentLevelMeter, &state, &statesize);
    if (status) {printf("Error retrieving meter data\n"); return 0.0f;}
    return state[0].mAveragePower;
}

- (void) addFilter: (double) sample
{
    double filter_val = 0;
    int f_n;
    
    //20k - 19999.35
    
    if(filter_freq == 10){
        
        double f_b[11] = {       0.059022873230480        ,           0  , -0.295114366152398           ,        0,
            
             0.590228732304797        ,           0  , -0.590228732304797     ,              0,
            
            0.295114366152398       ,            0  , -0.059022873230480};
        
        double f_a[11] = { 0.010000000000000  , 0.095413153757475 ,  0.413779187075651 , 1.073734736341020,
            
           1.845959334278435  , 2.196694668496635  , 1.832391704574420 ,  1.058009043180308,
            
            0.404722371317748  , 0.092638820735781  , 0.009637867991370  };
        
        f_n = 11;
        for(int i = 0;i < f_n; ++i){
            f_a[i] *= 100;
            f_b[i] /= 10000000000;
        }
        
        sample = sample/1000000000;
        
        x[0] = sample;
        
        filter_val = 0;
        for(int i = 0; i < f_n; ++i){
            filter_val += f_b[i]*x[i];
        }
        for(int i = 1; i < f_n; ++i){
            filter_val = filter_val - f_a[i]*y[i];
        }
    }

    
    //18k - 17640Hz
    
    if(filter_freq == 9){
    
        double f_b[11] = {      0.017154979844957        ,           0  ,  -0.085774899224784         ,          0  , 0.171549798449567  ,
            
            0 , -0.171549798449567      ,             0  , 0.085774899224784        ,           0   ,
            
            -0.017154979844957};
        
        double f_a[11] = {0.010000000000000 ,  0.079441982009365  , 0.300618495525144 ,  0.707291413621185 ,  1.141291385328760,
            
            1.316968578323478  , 1.099953804529410  , 0.656983075784465  , 0.269122154984701 ,  0.068542852885605 ,
            
            0.008315569584787   };
        
        f_n = 11;
        for(int i = 0;i < f_n; ++i){
            f_a[i] *= 100;
            f_b[i] /= 1000000;
        }
        
        sample = sample/1000000000;
        
        x[0] = sample;
        
        filter_val = 0;
        for(int i = 0; i < f_n; ++i){
            filter_val += f_b[i]*x[i];
        }
        for(int i = 1; i < f_n; ++i){
            filter_val = filter_val - f_a[i]*y[i];
        }
    }
    
    //17k - 17000.55
    if(filter_freq == 8){
        
        double f_b[11] = {   0.056677370813789           ,        0 , -0.283386854068947          ,         0,
            
           0.566773708137895        ,           0 ,  -0.566773708137895            ,       0,
            
           0.283386854068947      ,             0 , -0.056677370813789
        };
        
        double f_a[11] = {     0.010000000000000  , 0.075040416067361 ,  0.275012330485005  , 0.636825789323422,
            
            1.025370253130545 , 1.195231050009445  , 1.020653533100696  , 0.630980446165424,
            
            0.271234577578068  , 0.073669165418582  , 0.009772105551607
        };
        
        f_n = 11;
        for(int i = 0;i < f_n; ++i){
            f_a[i] *= 100;
            f_b[i] /= 100000000000;
        }
        
        sample = sample/1000000000;
        
        x[0] = sample;
        
        filter_val = 0;
        for(int i = 0; i < f_n; ++i){
            filter_val += f_b[i]*x[i];
        }
        for(int i = 1; i < f_n; ++i){
            filter_val = filter_val - f_a[i]*y[i];
        }
    }

    
    //16k - 16008.3
    if(filter_freq == 7){
        
        double f_b[11] = {    0.010920602240607          ,         0 , -0.054603011203036       ,            0,
            
            0.109206022406072          ,         0  , -0.109206022406072        ,           0,
            
            0.054603011203036        ,           0  , -0.010920602240607
        };
        
        double f_a[11] = {      1.000000000000000 ,  5.773041181428962 , 17.904195846372545 , 36.525776582513515,
            
            53.886209004889494 ,  59.309112631847313 , 49.408438885884777 , 30.707330654603133,
            
            13.801047878942700 ,  4.080074546132153  , 0.648042614156241
        };
        
        f_n = 11;
        for(int i = 0;i < f_n; ++i){
            f_a[i] *= 1;
            f_b[i] /= 10000;
        }
        
        sample = sample/1000000000;
        
        x[0] = sample;
        
        filter_val = 0;
        for(int i = 0; i < f_n; ++i){
            filter_val += f_b[i]*x[i];
        }
        for(int i = 1; i < f_n; ++i){
            filter_val = filter_val - f_a[i]*y[i];
        }
    }

    
    //15k - 15016.05
    if(filter_freq == 6){
        
        double f_b[11] = {     0.095586595707238          ,         0 ,  -0.477932978536188      ,            0,
            
              0.955865957072377      ,             0 , -0.955865957072377             ,      0,
            
            0.477932978536188          ,        0 , -0.095586595707238
            
        };
        
        double f_a[11] = {     1.000000000000000   , 5.371838232116550 , 16.526528763726454 , 33.819114895048820,
            
              51.113583984842457 , 58.177121928232381 , 50.948884171959833 , 33.601519955668529,
            
             16.367286034805240 ,  5.302934902842617  , 0.983992331407034
        };
        
        f_n = 11;
        for(int i = 0;i < f_n; ++i){
            f_a[i] *= 1;
            f_b[i] /= 1000000000000;
        }
        
        sample = sample/1000000000;
        
        x[0] = sample;
        
        filter_val = 0;
        for(int i = 0; i < f_n; ++i){
            filter_val += f_b[i]*x[i];
        }
        for(int i = 1; i < f_n; ++i){
            filter_val = filter_val - f_a[i]*y[i];
        }
    }

    
    //14k - 14001.75
    if(filter_freq == 5){
        
        double f_b[11] = {    0.018614763098832         ,           0 ,  -0.093073815494161          ,          0  , 0.186147630988322,
            
             0 , -0.186147630988322       ,            0  , 0.093073815494161         ,          0,
            
            -0.018614763098832
        };
        
        double f_a[11] = {   1.000000000000000  , 4.105302554375984  ,11.722966904229590  ,21.895783037307275 , 32.348437687059736,
            
            35.853208055651542 , 32.229340381789378  , 21.734852294506595 , 11.593961572205068 ,  4.045177561276354,
            
           0.981726528894496
        };
        
        f_n = 11;
        for(int i = 0;i < f_n; ++i){
            f_a[i] *= 1;
            f_b[i] /= 100000000000;
        }
        
        sample = sample/1000000000;
        
        x[0] = sample;
        
        filter_val = 0;
        for(int i = 0; i < f_n; ++i){
            filter_val += f_b[i]*x[i];
        }
        for(int i = 1; i < f_n; ++i){
            filter_val = filter_val - f_a[i]*y[i];
        }
    }

    
    //12k - 11907
    if(filter_freq == 4){
        
        double f_b[11] = {    0.056677370813790          ,         0  , -0.283386854068952        ,            0,
            
                       0.566773708137904      ,             0 ,  -0.566773708137904            ,       0,
            
            0.283386854068952          ,         0 , -0.056677370813790

        };
        
        double f_a[11] = {    1.000000000000000  , 1.247630353652111 ,  5.599580363564491 ,  5.122888973895252,
           
            11.786734982349806 ,  7.727256790397291  , 11.732516001427289  , 5.075866710517700,
            
             5.522660986483968 ,  1.224831786939120  , 0.977210555160728
        };
        
        f_n = 11;
        for(int i = 0;i < f_n; ++i){
            f_a[i] *= 1;
            f_b[i] /= 100000000000;
        }
        
        sample = sample/1000000000;
        
        x[0] = sample;
        
        filter_val = 0;
        for(int i = 0; i < f_n; ++i){
            filter_val += f_b[i]*x[i];
        }
        for(int i = 1; i < f_n; ++i){
            filter_val = filter_val - f_a[i]*y[i];
        }
    }

    //10k - 9922.5
    if(filter_freq == 3){
        
        double f_b[11] = {     0.018614763098833         ,          0  , -0.093073815494165       ,           0,
            
             0.186147630988331      ,             0  , -0.186147630988331         ,          0 ,
            
             0.093073815494165        ,           0 ,  -0.018614763098833
        };
        
        double f_a[11] = {1.000000000000000  , -1.564977424727201  ,  5.961220114154655 , -6.543461189963321,
       
            
            12.902544480149881 , -9.934793029484865 , 12.855041215442172 , -6.495367748076166,
            
            5.895619958628042 , -1.542057248779998  , 0.981726528894496
        };
        
        f_n = 11;
        for(int i = 0;i < f_n; ++i){
            f_a[i] *= 1;
            f_b[i] /= 100000000000;
        }
        
        sample = sample/1000000000;
        
        x[0] = sample;
        
        filter_val = 0;
        for(int i = 0; i < f_n; ++i){
            filter_val += f_b[i]*x[i];
        }
        for(int i = 1; i < f_n; ++i){
            filter_val = filter_val - f_a[i]*y[i];
        }
    }
    //5k - 4983.3
    if(filter_freq == 2){
        double f_b[11] = { 0.014070799498726         ,          0 , -0.070353997493629      ,             0 ,  0.140707994987259,
            
              0 , -0.140707994987259        ,           0  , 0.070353997493629           ,        0,
            
            -0.014070799498726};
        
        double f_a[11] = {   0.010000000000000 , -0.075629869995843  , 0.278518890674917 , -0.646923718486461  , 1.043230465852558,
            
             -1.216292561757542 ,  1.037474457788064 , -0.639804628757438  , 0.273934108862138 , -0.073974486826771,
            
             0.009727153409855};
        
        f_n = 11;
        for(int i = 0;i < f_n; ++i){
            f_a[i] *= 100;
            f_b[i] /= 10000000000;
        }
        
        sample = sample/1000000000;
        
        x[0] = sample;
        
        filter_val = 0;
        for(int i = 0; i < f_n; ++i){
            filter_val += f_b[i]*x[i];
        }
        for(int i = 1; i < f_n; ++i){
            filter_val = filter_val - f_a[i]*y[i];
        }
    }
    //2k - 1984.5
    if(filter_freq == 1){
    
        double f_b[11] = {   0.018840338705000     ,              0  , -0.094201693524998           ,        0  , 0.188403387049997,
            
              0 , -0.188403387049997      ,             0 ,  0.094201693524998       ,            0,
            
            -0.018840338705000};
    
        double f_a[11] = {   0.010000000000000 , -0.095584661769313  , 0.414993414447699 , -1.077435126087439  , 1.852154178152878,
    
            -2.202574960820804 ,  1.834984080609865 , -1.057551349327175 ,  0.403558699226997 , -0.092089242925826,

    
            0.009544999252386};
        
        f_n = 11;
        for(int i = 0;i < f_n; ++i){
            f_a[i] *= 100;
            f_b[i] /= 1000000000;
        }
     
        sample = sample/1000000000;
        
        x[0] = sample;
        
        filter_val = 0;
        for(int i = 0; i < f_n; ++i){
            filter_val += f_b[i]*x[i];
        }
        for(int i = 1; i < f_n; ++i){
            filter_val = filter_val - f_a[i]*y[i];
        }
        
    }
    // 800hz
    if(filter_freq == 0){
        double f_b[9] = {
            0.033007297331272             ,      0 , -0.132029189325087      ,             0  , 0.198043783987631,
            
             0 , -0.132029189325087      ,             0  , 0.033007297331272};
        
        double f_a[9] =  {  1.000000000000000  , -7.926869767239982 , 27.540946956662790 , -54.778604685031652 , 68.220280951272301,
        
         -54.473538538918191 , 27.235046043996999 , -7.795170070865886 ,  0.977909136121742};
        
        f_n = 9;
        for(int i = 0;i < f_n; ++i){
            f_b[i] /= 100000000;
        }
        
        sample = sample/1000000000;
        
        x[0] = sample;
        
        filter_val = 0;
        for(int i = 0; i < f_n; ++i){
            filter_val += f_b[i]*x[i];
        }
        for(int i = 1; i < f_n; ++i){
            filter_val = filter_val - f_a[i]*y[i];
        }

    }
    
    
    
    
    
    y[0] = filter_val;
    double sum_val = y[0];
    for(int i = f_n-1; i > 0; --i){
        x[i] = x[i-1];
        y[i] = y[i-1];
        sum_val += fabs(y[i]);
    }
    if([decoder getCheck] == 0 && (sum_val/f_n > 0.002)){
        if(index_updated == 0){
      //  NSLog(@"input index reset");
        input_index = 0;
            index_updated = 1;
        }
    }
        
    
    input_values[input_index] = y[0];
    input_index = (input_index+1)%2000;
    
    if(input_index == 0){
        [self setMean_val];
    }
    
}

- (void) setMean_val
{
    
    double sum = 0;
    for(int i = 0; i < 2000; ++i){
        if(input_values[i] >= 0)
            sum += input_values[i];
        else
            sum -= input_values[i];
    }
    sum /= 2000;
    
    double val = sum;
    
    index_updated = 0;
    
    updated = 1;
    
    
    for(int i = 0; i < 9; ++i){
        mean_vals[i] = mean_vals[i+1];
        signal_values[i] = signal_values[i+1];
    }
    mean_vals[9] = val;
    
    if(val > threshold || mean_vals[9] - mean_vals[8] > threshold/2)
        signal_values[9] = '1';
    else if(val <= threshold || mean_vals[9] - mean_vals[8] < threshold/2)
        signal_values[9] = '0';
    
    [decoder setStr:signal_values];
    
    if([decoder getCheck] == 1){
        results = [NSString stringWithFormat:@""];
    }
    else if([decoder getCheck] > 1){
        NSMutableString *tmp = [[NSMutableString alloc]init];
        [tmp appendString:results];
        char char_result = [decoder getStr];
        if(char_result != ','){
            NSString *temp = [NSString stringWithFormat:@"%c",char_result];
            [tmp appendString:temp];
            results = tmp;
        }
        
    }


}

- (double*) getMean_val
{
    return mean_vals;
}

- (void) setSignal:(double) val
{
   
}
- (char*) getSignal{
    return signal_values;
}

- (int) getUpdated
{
    return updated;
}

- (void) setUpdated:(int) t
{
    updated = t;
}

- (NSString*) getString
{
    return results;
}

- (void) setThreshold:(double) val{
    threshold = val;
}

- (double) getThreshold{
    return threshold;
}

- (void) setFreq:(int) t{
    filter_freq = t;
}

- (int) getCheck{
    return [decoder getCheck];
}

@end
