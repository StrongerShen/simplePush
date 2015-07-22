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
    int appdelegateTag;
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
    
    //badge 歸零
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    //第一次使用將連結logingViewController
    if ([mem_id length] == 0) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        HomeViewController *login = [storyBoard instantiateViewControllerWithIdentifier:@"LOGIN"];
        self.window.rootViewController = login;
    }
    
    NSDictionary *pushDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(pushDict)
    {
        [self application:application didReceiveRemoteNotification:pushDict];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    //找出根目錄來pop指定目標
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    
    //執行pop動作
    [navController popToRootViewControllerAnimated:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    appdelegateTag = 1;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"RELOADLIST" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSString* receiveDeviceToken = [deviceToken description];
    receiveDeviceToken = [receiveDeviceToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    receiveDeviceToken = [receiveDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Device Token:%@",receiveDeviceToken);
    
    //將deviceToken 傳送至 HomeViewController.m
    if (receiveDeviceToken) {
        //將收到的deviceToken存入userDefault
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:receiveDeviceToken forKey:@"device_token"];
        [userDefault synchronize];
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
    
    //badge++
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
    
    //trigger Notification Center
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"RELOADLIST" object:nil];
    
    //儲存要顯示的完整訊息ID
    nowInfo = [[NSMutableDictionary alloc]initWithDictionary:userInfo[@"aps"]];

    
    //將當下收到的userInfo儲存，透過進入前景時，取出message ID 進行內容讀取，並將rootViewController 設定為 MessageDetailViewController
    if (nowInfo != nil && appdelegateTag == 1) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        MessageDetailViewController *mdvc = [storyBoard instantiateViewControllerWithIdentifier:@"FULLMSG"];
        
        mdvc.receiveMessageID = nowInfo[@"newsId"];
        mdvc.receiveMessageTitle = nowInfo[@"alert"];
        mdvc.MessageDetailViewControllerTag = appdelegateTag;
        
        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        [navController.visibleViewController.navigationController pushViewController:mdvc animated:YES];
        appdelegateTag = 0;
    }
    
}
@end
