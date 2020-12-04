//
//  main.m
//  first
//
//  Created by aadesh on 04/12/2020.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if(argc < 2) {
            printf("Usage: first fullpath/to/audiofile\n");
        }
        
        NSString *audioFilePath = [[NSString stringWithUTF8String:argv[1]] stringByExpandingTildeInPath];
        NSURL *audioURL = [NSURL fileURLWithPath:audioFilePath];
        AudioFileID audioFile;
        OSStatus theErr = noErr;
        theErr = AudioFileOpenURL((__bridge CFURLRef)audioURL,
                                  kAudioFileReadPermission,
                                  0,
                                  &audioFile);
        assert (theErr == noErr);
        UInt32 dictionarySize = 0;
        theErr = AudioFileGetPropertyInfo(audioFile,
                                          kAudioFilePropertyInfoDictionary,
                                          &dictionarySize,
                                          0);
        assert (theErr == noErr);
        
        CFDictionaryRef dictionary;
        
        theErr = AudioFileGetProperty(audioFile,
                                      kAudioFilePropertyInfoDictionary,
                                      &dictionarySize,
                                      &dictionary);
        assert (theErr == noErr);
        NSLog (@"dictionary: %@", dictionary);
        CFRelease (dictionary);
        theErr = AudioFileClose (audioFile);
        assert (theErr == noErr);
        
        return 0;
    }
}