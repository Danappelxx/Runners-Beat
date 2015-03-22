////
////  AppDelegate.m
////  Run Beat
////
////  Created by Kyle Sandell on 3/21/15.
////  Copyright (c) 2015 Kyle Sandell. All rights reserved.
//
//
//#import "AppDelegate.h"
//
//@interface AppDelegate ()
//
//@end
//
//@implementation AppDelegate
//
//
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    // Override point for customization after application launch.
//    [[TLMHub sharedHub] setLockingPolicy:TLMLockingPolicyNone];
//    
////    [self modalPresentMyoSettings];
//    return YES;
//}
//
//- (void)applicationWillResignActive:(UIApplication *)application {
//    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//}
//
//- (void)applicationDidEnterBackground:(UIApplication *)application {
//    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application {
//    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//}
//
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application {
//    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//}
//
//
//@end


// TutorialApp
// Created by Spotify on 04/09/14.
// Copyright (c) 2014 Spotify. All rights reserved.

#import <Spotify/Spotify.h>
#import "AppDelegate.h"
//#import <MyoKit/MyoKit.h>

static NSString * const kClientId = @"b25dc953e6ce49ef8c36fb32813177d8";
static NSString * const kCallbackURL = @"runners-beat-login://callback";
static NSString * const kTokenSwapServiceURL = @"http://192.168.89.173:1234/swap";

@interface AppDelegate ()

@property (nonatomic, readwrite) SPTAudioStreamingController *player;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    NSURL *loginURL = [auth loginURLForClientId:kClientId declaredRedirectURL:[NSURL URLWithString:kCallbackURL] scopes:@[SPTAuthStreamingScope]];
    
    [application performSelector:@selector(openURL:) withObject:loginURL afterDelay:0.1];
    
    // Override point for customization after application launch.
//    [[TLMHub sharedHub] setLockingPolicy:TLMLockingPolicyNone];
    
//    [self modalPresentMyoSettings];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if([[SPTAuth defaultInstance]canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url tokenSwapServiceEndpointAtURL:[NSURL URLWithString:kTokenSwapServiceURL] callback:^(NSError *error, SPTSession *session) {
            
            if (error != nil) {
                NSLog(@"** Auth error: %@", error);
                return;
            }
            
            [self playUsingSession:session];
        }];
        return YES;
    }
    
    return NO;
}

-(void)playUsingSession:(SPTSession *)session {
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:kClientId];
    }
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        
        [self.player loginWithSession:session callback:^(NSError *error) {
            
            if (error != nil) {
                NSLog(@"*** Enabling playback got error: %@", error);
                return;
            }
            
            [SPTRequest requestItemAtURI:[NSURL URLWithString:@"spotify:album:4L1HDyfdGIkACuygkt07T7"] withSession:nil callback:^(NSError *error, SPTAlbum *album){
                if (error != nil) {
                    NSLog(@"*** Album lookup got error %@", error);
                    return;
                }
                [self.player playTrackProvider:album callback:nil];
            }];
        }];
    }];
}

@end