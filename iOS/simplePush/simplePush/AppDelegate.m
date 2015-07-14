//
//  AppDelegate.m
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/25.
//  Copyright (c) 2015年 TOMIN. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "MessageDetailViewController.h"
#import "testViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //ios本身系統版本判定
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
    
    //判斷NSUserDefaults裡的device token若不存在值，設定rootViewController為login畫面
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *mem_id = [defaults objectForKey:@"memID"];
    //    NSString *memNO = [defaults objectForKey:@"memNo"];
    //    NSString *memID = [defaults objectForKey:@"memID"];
    //    NSString *memName = [defaults objectForKey:@"memName"];
    //    NSLog(@"背景移除後，重新進來APP，抓取使用者NO:%@,使用者名字:%@，裝置名稱:%@,DT:%@",memNO,memID,memName,device_token);
    
    //badge 歸零
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    //第一次使用將連結logingViewController
    if ([mem_id length] == 0) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        HomeViewController *login = [storyBoard instantiateViewControllerWithIdentifier:@"LOGIN"];
        self.window.rootViewController = login;
    }
    
    NSLog(@"你執行了didFinishLaunchingWithOptions");
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
        NSLog(@"你執行了applicationWillResignActive");
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"你執行了applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"RELOADLIST" object:nil];
    
    NSLog(@"你執行了applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog(@"你執行了applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSLog(@"你執行了applicationWillTerminate");
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* receiveDeviceToken = [deviceToken description];
    receiveDeviceToken = [receiveDeviceToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    receiveDeviceToken = [receiveDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //將deviceToken 傳送至 HomeViewController.m
    if (receiveDeviceToken) {
        
        //將收到的deviceToken存入userDefault
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:receiveDeviceToken forKey:@"device_token"];
        [userDefault synchronize];
    }else {
        NSLog(@"receiveDeviceToken 不存在");
    }
        NSLog(@"你執行了didRegisterForRemoteNotificationsWithDeviceToken");
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get device token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //badge++
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"RELOADLIST" object:nil];
    
    NSLog(@"%@",userInfo);
    
    //set content root controller
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    testViewController *testVC = [storyBoard instantiateViewControllerWithIdentifier:@"TEST"];
    
    
    
//    MessageDetailViewController *fullMsgVC = [storyBoard instantiateViewControllerWithIdentifier:@"FULLMSG"];
//    if (userInfo[@"newsId"]!= nil) {
//        fullMsgVC.receiveMessageID = userInfo[@"newsId"];
//        self.window.rootViewController = fullMsgVC;
//    }

}

@end
