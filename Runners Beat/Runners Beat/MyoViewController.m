//
//  ViewController.m
//  Run Beat
//
//  Created by Kyle Sandell on 3/21/15.
//  Copyright (c) 2015 Kyle Sandell. All rights reserved.
//
#import <MyoKit/MyoKit.h>
#import "MyoViewController.h"
#import "AppDelegate.h"

@interface MyoViewController ()
@property BOOL didConnectToMyo;
@property (nonatomic, retain) TLMMyo *myo;
@property TLMVector3 initialVector;
@property TLMVector3 secondVector;
@property int numVectorsTaken;
//@property (nonatomic, retain) NSTimer *timerForStepsPerMin;
@property (nonatomic, retain) NSDate *firstStep;
@property (nonatomic, retain) NSDate *thirdStep;
@property int steps;
@property float timeBetween;
@property int stepsPerMinute;

//@property (nonatomic, retain) UINavigationController *navigationController;
@end

@implementation MyoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.steps=0;
    self.timeBetween=0;
    //[self.timerForStepsPerMin ]
   /* NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"%H:%M:%S"];
    NSString *timeString = [formatter stringFromDate:date];*/
    [self holdUnlockForMyo:self.myo];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRecieveAccelerometerChange:)
                                                 name:TLMMyoDidReceiveAccelerometerEventNotification
                                               object:nil];
    
    
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
    
    
    //TODO: do something with the pose object.
   // NSLog(@"HELLO FROM POSE CHANGE");
}

- (void)didRecieveAccelerometerChange:(NSNotification*)notification {
    TLMAccelerometerEvent *accel = notification.userInfo[kTLMKeyAccelerometerEvent];
    TLMVector3 accelVector=accel.vector;
    self.secondVector=self.initialVector;
    self.initialVector=accelVector;
    if([self dotProduct:self.initialVector secondVector:self.secondVector]<0.09)
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
   
   @end
