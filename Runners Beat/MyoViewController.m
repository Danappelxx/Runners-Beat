//
//  ViewController.m
//  Run Beat
//
//  Created by Kyle Sandell on 3/21/15.
//  Copyright (c) 2015 Kyle Sandell. All rights reserved.
//

#import <MyoKit/MyoKit.h>
#include <stdlib.h>
//#import <Spotify/Spotify.h>
#import "MyoViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <Spotify/Spotify.h>

@interface MyoViewController ()

@property (nonatomic, strong) NSString *spotify_song_id;

@property int playChecker;

@property int stepsAverage; //step averagignggggg
@property int averageCount;
@property int lastStep;
@property int overflowCheck;
@property BOOL didConnectToMyo;//check if connected to myo
@property (nonatomic, retain) TLMMyo *myo;//myo instance
@property TLMVector3 initialVector;//dont matter
@property TLMVector3 secondVector;//domt matter
@property int numVectorsTaken;//dont matter
@property UILabel *BPM;//this is the label where

@property (nonatomic, retain) NSDate *firstStep;//dont matter
@property (nonatomic, retain) NSDate *thirdStep;//dont matter
@property int steps;//dont matter
@property float timeBetween;//dont matter
//THIS IS YOUR BPM YOU IDIOTS
//THIS IS YOUR BPM YOU IDIOTS//THIS IS YOUR BPM YOU IDIOTS
//THIS IS YOUR BPM YOU IDIOTS//THIS IS YOUR BPM YOU IDIOTS
//THIS IS YOUR BPM YOU IDIOTS
//THIS IS YOUR BPM YOU IDIOTS
//THIS IS YOUR BPM YOU IDIOTS
@property int stepsPerMinute;//THIS IS YOUR BPM YOU IDIOTS
//THIS IS YOUR BPM YOU IDIOTS
//THIS IS YOUR BPM YOU IDIOTS
//THIS IS YOUR BPM YOU IDIOTS//THIS IS YOUR BPM YOU IDIOTS
//THIS IS YOUR BPM YOU IDIOTS//THIS IS YOUR BPM YOU IDIOTS
@property NSString *clientID;//doesnt need any thing
@property NSString *clientSecret;//doesnt do anything
@property BOOL musicIsPaused;//check if music is paused or not
@property (nonatomic, retain) UITextField *calibrationField;//text field
@property (nonatomic, retain) NSUserDefaults *defaults;//where calibration val is stored
@property (nonatomic, retain) UILabel *calibLabel;//text field
@property (nonatomic, retain) UIImageView *albumArtwork;//imageview to show artwork
@property (nonatomic, retain) UIImage *albumWorkImage;//image to load into imageview with artwork
@property (nonatomic, retain) SPTSession *session;//session
@property (nonatomic, retain) SPTAudioStreamingController *streamer;//stream music
@property (nonatomic, readonly) BOOL isPlaying;

@property BOOL observerCheck;
//@property (nonatomic, retain) AVAudio
@property float calibrationValue;//calibration value for miyo

@end
//go to line 216, 95, 107
@implementation MyoViewController


- (void)processMinMax:(NSInteger)bpm {
    NSInteger tempminbpm = bpm - 10;
    NSInteger tempmaxbpm = bpm + 10;
    
    if (tempminbpm < 30) {
        tempminbpm = 30;
    }
    
    if (tempmaxbpm < 50) {
        tempmaxbpm = 50;
    }
    
    if (tempmaxbpm > 250) {
        tempmaxbpm = 250;
        tempminbpm = 250;
    }
    
    NSString *minsteps = [NSString stringWithFormat:@"%ld", (long)tempminbpm];
    NSString *maxsteps = [NSString stringWithFormat:@"%ld", (long)tempmaxbpm];
    
    NSLog(@"%@",minsteps);
    NSLog(@"%@",maxsteps);
    
    NSString *baseUrl = @"http://developer.echonest.com/api/v4/song/search?api_key=";
    NSString *apikey = @"8C5RHDLARNPQQW7FZ";
    NSString *urlQueries = @"&format=json&results=100&&min_tempo=";
    NSString *minTempo = (@"%@", minsteps);
    NSString *inBetween = (@"&max_tempo=");
    NSString *maxTempo = (@"%@", maxsteps);
    NSString *buckets = @"&bucket=audio_summary&bucket=id:spotify&bucket=tracks";
    NSString *minEnergy = (@"&min_energy=0.1");
    NSString *minHotttnesss = (@"&artist_min_hotttnesss=0.25");
    
    // allows for customization
    NSString *serverAddress=[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", baseUrl, apikey, urlQueries, minTempo, inBetween, maxTempo, buckets, minEnergy, minHotttnesss];
    
    NSMutableDictionary *responseData = [self getSongInfo:serverAddress];
    
    NSLog(@"%@", responseData);
    
    
    //    NSLog(@"%@", responseData[@"response"][@"artists"][0][@"@%", @"foreign_ids"][0][@"catalog"]);
    
    if ([responseData[@"response"][@"songs"] count] < 1) {
        [self processMinMax:(self.stepsAverage)];
        NSLog(@"Empty Query");
    } else {
        
        NSInteger randomint = arc4random_uniform([responseData[@"response"][@"songs"] count]);
        
        NSLog(@"%ld", (long)randomint);
        
        self.spotify_song_id = [NSString stringWithFormat:@"%@", responseData[@"response"][@"songs"][randomint][@"tracks"][0][@"foreign_id"]];

        NSLog(@"%@", self.spotify_song_id);
    }

}


- (IBAction)sendGetRequest:(UIButton *)sender {
    
    [self processMinMax:(self.stepsPerMinute)];
    
}

- (NSMutableDictionary*)getSongInfo:(NSString *)requestURL {
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:10
     ];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    
    NSData *responseDataJSON = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    //    NSString *response = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    //
    //    NSLog(@"%@", response);
    
    NSError *error;
    NSMutableDictionary *responseData = [NSJSONSerialization
                                         JSONObjectWithData:responseDataJSON
                                         options:NSJSONReadingMutableContainers
                                         error:&error];
    
    
    
    return responseData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.defaults=[NSUserDefaults standardUserDefaults];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    bool havePrintBoxesOnTop=true;//THIS LINE IS SO IMPORTANT, make this true to show calibration and bpm, false to not show anything
    self.musicIsPaused=0;
    if(havePrintBoxesOnTop){
        self.calibrationField=[[UITextField alloc] initWithFrame:CGRectMake((12+140), 24, 100, 24)];
        [self.view addSubview:self.calibrationField];
        if ([self.defaults objectForKey:@"Calibration"]!=NULL) {
            self.calibrationValue=[[self.defaults objectForKey:@"Calibration"] floatValue];
            [self.calibrationField setText:[NSString stringWithFormat:@"%f", self.calibrationValue]];
        }
        else{
            self.calibrationValue=0.09;
            [self.defaults setObject:[NSNumber numberWithFloat:self.calibrationValue] forKey:@"Calibration"];
            [self.calibrationField setText:[NSString stringWithFormat:@"%f", self.calibrationValue]];
        }
        //[self.BPM initWithFrame:CGRectMake((self.view.frame.size.width/2), (self.view.frame.size.height/2), 150, 50)];
        self.BPM=[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-(self.view.frame.size.width*.25), 24, 150, 24)];
        [self.BPM setText:@"BPM: 0"];
        //self.BPM.frame=CGRectMake();
        [self.view addSubview:self.BPM];
        
        self.calibLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 24, 140, 24)];
        [self.calibLabel setText:@"Calibration Level: "];
        [self.view addSubview:self.calibLabel];
    }
    
    self.albumWorkImage=[[UIImage alloc] init];
    self.albumArtwork=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-150, self.view.center.y-150, 300, 300)];
    [self.view addSubview:self.albumArtwork];
    
    
    self.clientID=@"b25dc953e6ce49ef8c36fb32813177d8";
    self.clientSecret=@"ff3e24c8633c4176ab30f5c748e23db8";
    // Do any additional setup after loading the view, typically from a nib.
    self.steps=0;
    self.timeBetween=0;
    
    [self holdUnlockForMyo:self.myo];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRecieveAccelerometerChange:)
                                                 name:TLMMyoDidReceiveAccelerometerEventNotification
                                               object:nil];
    [self.defaults synchronize];
    
    if (self.streamer == nil)
    {
        self.streamer = [[SPTAudioStreamingController alloc] initWithClientId:self.clientID];
    }
    [self.streamer addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    BOOL isPlaying = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
    NSLog(@"%d", isPlaying);
    if (isPlaying == NO && self.observerCheck == true)
    {
        [self selectNextSong];
    }
}

-(void)dismissKeyboard {
    [self.calibrationField resignFirstResponder];
    self.calibrationValue=[self.calibrationField.text floatValue];
    [self.defaults setObject:[NSNumber numberWithFloat:self.calibrationValue] forKey:@"Calibration"];
}


-(void)playPause{//pause/play
    //insert code to play or pause music
    if (self.playChecker == nil)
    {
        self.playChecker = 1;
        [self selectNextSong];
        self.musicIsPaused = YES;
    }
    [self.streamer setIsPlaying:self.musicIsPaused callback:nil];
    NSLog(@"%@", self.musicIsPaused);
}

-(void)skip{//skip music
    //insert code to skip music
    //pick next song
    [self selectNextSong];
    NSLog(@"Skipped!");
    
}

-(void)selectNextSong{//pcik the next song
    //pick song here
    [self processMinMax:([self stepsAverage])];
    //set album artwork here
    //start playing song here
    if (self.streamer == nil)
    {
        self.streamer = [[SPTAudioStreamingController alloc] initWithClientId:self.clientID];
    }
    [self.streamer addObserver:self forKeyPath:@"currentPlaybackPosition" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.streamer loginWithSession:_session callback:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        [SPTRequest requestItemAtURI:[NSURL URLWithString:self.spotify_song_id]
                         withSession:nil
                            callback:^(NSError *error, SPTTrack *track) {
                                
                                if (error != nil) {
                                    NSLog(@"*** Track lookup got error %@", error);
                                    return;
                                }
                                [self.streamer playTrackProvider:track callback:nil];
                                self.observerCheck = true;
                            }];
    }
     ];
    
}

-(void)viewDidAppear: (BOOL)animated{
    
    if (!self.didConnectToMyo) {
        [self modalPresentMyoSettings];
        self.didConnectToMyo=TRUE;
    }
}

- (void)holdUnlockForMyo:(TLMMyo *)myo {
    [myo unlockWithType:TLMUnlockTypeHold];
}

- (void)endHoldUnlockForMyo:(TLMMyo *)myo immediately:(BOOL)immediately {
    if (immediately) {
        [myo lock];
    } else {
        [myo unlockWithType:TLMUnlockTypeTimed];
    }
}

- (void)didReceivePoseChange:(NSNotification*)notification {
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    if(pose.type==TLMPoseTypeFist)
    {
        NSLog(@"fist");
        [self playPause];
        self.musicIsPaused= !self.musicIsPaused;
    }
    if(pose.type==TLMPoseTypeWaveIn || pose.type==TLMPoseTypeWaveOut)
    {
        NSLog(@"Wave in/ wave out");
        [self skip];
    }
    
    //TODO: do something with the pose object.
    // NSLog(@"HELLO FROM POSE CHANGE");
}

- (void)didRecieveAccelerometerChange:(NSNotification*)notification {
    TLMAccelerometerEvent *accel = notification.userInfo[kTLMKeyAccelerometerEvent];
    TLMVector3 accelVector=accel.vector;
    self.secondVector=self.initialVector;
    self.initialVector=accelVector;
    // NSMutableArray *averageDataList = [NSMutableArray  arrayWithCapacity: 50];
    NSInteger averageDataList[50];
    int summation;
    int overflowCheck = 1;
    for (int i = 0; i < 50; i ++)
    {
        averageDataList[i] = 0;
    }
    int stepCount;
    if([self dotProduct:self.initialVector secondVector:self.secondVector]<self.calibrationValue)
    {
        self.steps++;
        if (self.steps==1) {
            self.firstStep=[NSDate date];
            self.timeBetween=0;
        }
        else if (self.steps==3){
            self.thirdStep=[NSDate date];
            self.steps=0;
            self.timeBetween=[self getIntervalBetweenTimes:self.firstStep date2:self.thirdStep];
            int stepsMin=[self getApproxStepsPerMin:self.timeBetween];
            self.steps=1;
            self.firstStep=self.thirdStep;
            
            NSLog(@"Steps per minute: %d", self.stepsPerMinute); // REMOVE LATER!!!! (DONT MESS WITH KYLE)
            if (stepsMin<300) {
                self.stepsPerMinute=stepsMin;
                stepCount = stepsMin;
                if (stepCount != self.lastStep){
                    averageDataList[self.averageCount] = stepCount;
                    if (self.averageCount < 50){
                        self.averageCount++;
                        overflowCheck = 0;
                    } else {
                        self.averageCount = 0;
                    }
                    for (int i = 0; i < 50; i++){
                        summation += averageDataList[i];
                    }
                    self.averageCount = summation/(50-((self.averageCount)*self.overflowCheck));
                    self.lastStep = stepCount;
                }
                NSLog(@"Steps min (variable): %i",stepsMin);
                NSLog(@"%f",self.timeBetween/2);
                self.BPM.text=[NSString stringWithFormat:@"BPM: %i ",stepsMin];
            }
            //NSLog(@"%i",stepsMin);
        }
    }
    
    //TODO: do something with the pose object.
    // NSLog(@"HELLO FROM ACCELEROMETER CHANGE");
}
-(float)getIntervalBetweenTimes:(NSDate *)date1 date2:(NSDate *)date2
{
    NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:date1];
    float ret=secondsBetween;
    return ret;
}

-(int)getApproxStepsPerMin:(float)interval{
    float secondsPerStep=(interval);//how long one step takes
    int stepsMin=60/secondsPerStep;
    return stepsMin;
}

-(float)dotProduct:(TLMVector3)vector secondVector:(TLMVector3)secondVector
{
    float product=((vector.x*secondVector.x)+(vector.y*secondVector.y)+(vector.z*secondVector.z));
    return product;
}


- (void)modalPresentMyoSettings {
    UINavigationController *settings = [TLMSettingsViewController settingsInNavigationController];
    
    [self presentViewController:settings animated:YES completion:nil];
}
- (void)pushMyoSettings {
    TLMSettingsViewController *settings = [[TLMSettingsViewController alloc] init];
    
    [self.navigationController pushViewController:settings animated:YES];
    [self presentViewController:self.navigationController animated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewDidUnload{
    [super viewDidUnload];
    [self endHoldUnlockForMyo:self.myo immediately:YES];
}

@end
