//
//  ViewController.m
//  Run Beat
//
//  Created by Kyle Sandell on 3/21/15.
//  Copyright (c) 2015 Kyle Sandell. All rights reserved.
//

#import <MyoKit/MyoKit.h>
//#import <Spotify/Spotify.h>
#import "MyoViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <Spotify/Spotify.h>

@interface MyoViewController ()

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

//@property (nonatomic, retain) AVAudio
@property float calibrationValue;//calibration value for miyo

@end
//go to line 216, 95, 107
@implementation MyoViewController

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
    
}

-(void)dismissKeyboard {
    [self.calibrationField resignFirstResponder];
    self.calibrationValue=[self.calibrationField.text floatValue];
    [self.defaults setObject:[NSNumber numberWithFloat:self.calibrationValue] forKey:@"Calibration"];
}


-(void)playPause{//pause/play
    //insert code to play or pause music
    
     if(self.musicIsPaused)
     {
        //play music
     }
     else{
        //pause music
     }
    
}
-(void)skip{//skip music
    //insert code to skip music
    //skip
}

-(void)selectNextSong{//pcik the next song
    //pick song here
    //set album artwork here
    //start playing song here
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
            self.stepsPerMinute=stepsMin;
            if (stepsMin<300) {
                NSLog(@"%i",stepsMin);
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
