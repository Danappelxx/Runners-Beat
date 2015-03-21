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


//@property (nonatomic, retain) UINavigationController *navigationController;
@end

@implementation MyoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
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
    NSLog(@"HELLO FROM POSE CHANGE");
}

- (void)didRecieveAccelerometerChange:(NSNotification*)notification {
    TLMAccelerometerEvent *accel = notification.userInfo[kTLMKeyAccelerometerEvent];
    TLMVector3 accelVector=accel.vector;
    self.initialVector=self.secondVector;
    self.secondVector=accelVector;
    
    //TODO: do something with the pose object.
    NSLog(@"HELLO FROM ACCELEROMETER CHANGE");
}

- (
   
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
