//
//  AppDelegate.m
//  simplePush
//
//  Created by SammaYang on 2015/6/5.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

#import "AppDelegate.h"

static NSString * const kJSON = @"http://192.168.0.11/PHP_LAB/simple_push_sir/DeviceRegister.php";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // For iOS 8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    UIAlertView *errorAlterView=[[UIAlertView alloc]initWithTitle:@"title"
//                                                          message:@"applicationWillEnterForeground"
//                                                         delegate:nil
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil, nil];
//    
//    [errorAlterView show];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* receiveDeviceToken = [deviceToken description];
    receiveDeviceToken = [receiveDeviceToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    receiveDeviceToken = [receiveDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //將deviceToken 傳送至 HomeViewController.m
    if (receiveDeviceToken) {
        NSDictionary *passDTdictionary = @{@"device_Token":receiveDeviceToken};
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"passDT" object:nil userInfo:passDTdictionary];
    }else {
        NSLog(@"receiveDeviceToken 不存在");
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get device token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification");
    UIAlertView *errorAlterView=[[UIAlertView alloc]initWithTitle:@"title"
                                                          message:@"didReceiveRemoteNotification"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil, nil];
    
    [errorAlterView show];
}
@end
