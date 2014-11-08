//
//  JSAudioRecorder.h
//  JSRecordingDemo
//
//  Created by Bob Zhou on 2014-11-08.
//  Copyright (c) 2014 Bob Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "lame/lame.h"


@interface JSAudioRecorder : NSObject<AVAudioRecorderDelegate, AVAudioPlayerDelegate>{
    float recordingTime;
}


+ (JSAudioRecorder *) sharedInstance;

- (void)startRecording;
- (void)stopRecording;
- (void)clear;
- (void)play;
- (void)upload:(NSURL *)url;
- (NSString *)encode;

- (BOOL)parseURL:(NSURL *)url;

@property (nonatomic, weak) UIWebView *linkedWebview;
@property (nonatomic, strong) AVAudioRecorder *theRecorder;
@property (nonatomic, strong) AVAudioPlayer *thePlayer;
@property (nonatomic, strong) NSTimer *theTimer;

@end
