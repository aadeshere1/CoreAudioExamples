//
//  main.m
//  CAToneFileGenerator
//
//  Created by aadesh on 04/12/2020.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define SAMPLE_RATE 44100
#define DURATION 5.0
//#define FILENAME_FORMAT @"%0.3f-square.aif"
//#define FILENAME_FORMAT @"%0.3f-saw.aif"
#define FILENAME_FORMAT @"%0.3f-sine.aif"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if(argc < 2){
            printf("Usage: CAToneFileGenerator n\n(where n is tone in hertz)");
            return -1;
        }
        
        double hz = atof(argv[1]);
        assert (hz > 0);
        NSLog (@"generating %f hz tone", hz);
        
        NSString *fileName = [NSString stringWithFormat:FILENAME_FORMAT, hz];
        NSString *filePath = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:fileName];
        NSURL *fileURL = [NSURL fileURLWithPath: filePath];
        
//        prepare format
        AudioStreamBasicDescription asbd;
        memset(&asbd, 0, sizeof(asbd));
        asbd.mSampleRate = SAMPLE_RATE;
        asbd.mFormatID = kAudioFormatLinearPCM;
        asbd.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        asbd.mBitsPerChannel = 16;
        asbd.mChannelsPerFrame = 1;
        asbd.mFramesPerPacket = 1;
        asbd.mBytesPerFrame = 2;
        asbd.mBytesPerPacket = 2;
        
//        setup file
        AudioFileID audioFile;
        OSStatus audioErr = noErr;
        
        audioErr = AudioFileCreateWithURL((__bridge CFURLRef)fileURL, kAudioFileAIFFType, &asbd, kAudioFileFlags_EraseFile, &audioFile);
        
        assert (audioErr == noErr);
        
//        start writing samples
        long maxSampleCount = SAMPLE_RATE * DURATION;
        
        long sampleCount = 0;
        UInt32 bytesToWrite = 2;
        double waveLengthInSamples = SAMPLE_RATE / hz;
    
        
        while (sampleCount < maxSampleCount) {
            for(int i=0; i<waveLengthInSamples; i++){
                // square wave
//                SInt16 sample;
//                if(i < waveLengthInSamples/2){
//                    sample = CFSwapInt16HostToBig(SHRT_MAX);
//                } else {
//                    sample = CFSwapInt16HostToBig(SHRT_MIN);
//                }
                
//               saw wave
//                SInt16 sample = CFSwapInt16HostToBig(((i / waveLengthInSamples) * SHRT_MAX *2) - SHRT_MAX);
                
//                Sine wave
                SInt16 sample = CFSwapInt16HostToBig((SInt16) SHRT_MAX * sin (2 * M_PI * (i / waveLengthInSamples)));
                
                audioErr = AudioFileWriteBytes(audioFile, false, sampleCount*2, &bytesToWrite, &sample);
                assert (audioErr == noErr);
                sampleCount++;
            }
        }
        audioErr = AudioFileClose(audioFile);
        assert (audioErr == noErr);
        NSLog (@"wrote %d samples", sampleCount);
    }
    return 0;
}
