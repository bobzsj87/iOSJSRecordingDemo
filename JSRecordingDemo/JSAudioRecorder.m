//
//  JSAudioRecorder.m
//  JSRecordingDemo
//
//  Created by Bob Zhou on 2014-11-08.
//  Copyright (c) 2014 Bob Zhou. All rights reserved.
//

#import "JSAudioRecorder.h"

#define SAMPLE_RATE 44100.0
#define WAVE_UPDATE_FREQ 0.05


@interface JSAudioRecorder()

- (void)invalidateTimer;

- (void)updateMeter;

@end


@implementation JSAudioRecorder

@synthesize thePlayer;
@synthesize theRecorder;
@synthesize theTimer;

- (id)init
{
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}

+ (JSAudioRecorder *)sharedInstance
{

    static JSAudioRecorder * _dInstance;
    
    @synchronized (self) {
        if (_dInstance == nil){
            _dInstance = [[[self class] alloc] init];
        }
        
        return _dInstance;
    }
    return nil;
}




- (void)startRecording
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        return;
    }
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:SAMPLE_RATE] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    
    // Create a new dated file
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *recorderFilePath = [NSString stringWithFormat:@"%@%f.caf", NSTemporaryDirectory(), [now timeIntervalSinceReferenceDate]];
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    if(self.theRecorder){[self.theRecorder stop];self.theRecorder = nil;}
    
    theRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!theRecorder){
        NSLog(@"Recorder uninitialized %@", err);
        return;
    }
    
    //prepare to record
    [theRecorder setDelegate:self];
    [theRecorder prepareToRecord];
    theRecorder.meteringEnabled = YES;
    
    
    // start recording
    [theRecorder record];
    
    [self invalidateTimer];
    self.theTimer = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQ target:self selector:@selector(updateMeter) userInfo:nil repeats:YES];
    [self.theTimer fire];
}

- (void)updateMeter
{
    [theRecorder updateMeters];
    recordingTime += WAVE_UPDATE_FREQ;
    float peakPower = [theRecorder averagePowerForChannel:0];
    double peakPowerForChannel = 100 * pow(10, (0.05 * peakPower));
    
    if (self.linkedWebview){
        [self.linkedWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"updateMeter(%f, %f)", peakPowerForChannel, recordingTime]];
    }
}

- (void)stopRecording
{
    [self invalidateTimer];
    [theRecorder stop];
}

- (void)invalidateTimer
{
    [self.theTimer invalidate];
    self.theTimer = nil;
    recordingTime = 0;
}

- (void)play
{
    NSError *err = nil;
    NSLog(@"start playing: %@", theRecorder.url);
    if(self.thePlayer){[self.thePlayer stop];self.thePlayer = nil;}
    
    thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:theRecorder.url error:&err];
    if (err){
        NSLog(@"%@", err);
    }
    thePlayer.delegate = self;
    [thePlayer play];
}

- (void)clear
{
    [theRecorder deleteRecording];
}


- (BOOL)parseURL:(NSURL *)url
{
    NSArray *seg = [url.absoluteString componentsSeparatedByString:@":"];
    
    if (seg.count == 2 && [[seg objectAtIndex:0] isEqualToString:@"iosrecorder"]){
        NSString *action = [seg objectAtIndex:1];
        if ([action isEqualToString:@"record"]){
            [self startRecording];
        }
        else if ([action isEqualToString:@"stop"]){
            [self stopRecording];
        }
        else if ([action isEqualToString:@"play"]){
            [self play];
        }
        else if ([action isEqualToString:@"clear"]){
            [self clear];
        }
        else if ([action isEqualToString:@"upload"]){
            [self upload:nil];
        }
        return NO;
    }
    return YES;
}

- (void)upload:(NSURL *)url
{
    NSLog(@"%@", [self encode]);
}

#pragma mark delegates
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    NSLog (@"%@", aRecorder.url);
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"%@", player.url);
}


#pragma mark mp3

- (NSString *)encode
{
    NSString *cafFilePath = theRecorder.url.path;
    NSString *mp3FilePath =  [cafFilePath stringByAppendingString:@".mp3"];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:NSASCIIStringEncoding], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, SAMPLE_RATE);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        return mp3FilePath;
    }
}


@end
