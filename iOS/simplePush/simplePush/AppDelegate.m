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
{
    NSDictionary *nowInfo;
}
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
    
        NSLog(@"你執行了applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    NSLog(@"你執行了applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"RELOADLIST" object:nil];
    
    NSLog(@"你執行了applicationWillEnterForeground");
    
    //將當下收到的userInfo儲存，透過進入前景時，取出message ID 進行內容讀取，並將rootViewController 設定為 MessageDetailViewController
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    MessageDetailViewController *mdvc = [storyBoard instantiateViewControllerWithIdentifier:@"FULLMSG"];
    mdvc.receiveMessageID = nowInfo[@"newsId"];
    [navController.visibleViewController.navigationController pushViewController:mdvc animated:YES];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
        NSLog(@"你執行了applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
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
//        NSLog(@"你執行了didRegisterForRemoteNotificationsWithDeviceToken");
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get device token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //badge++
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
    
    //trigger Notification Center
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"RELOADLIST" object:nil];
    
    nowInfo = [[NSDictionary alloc]init];
    nowInfo = userInfo[@"aps"];

}

@end
