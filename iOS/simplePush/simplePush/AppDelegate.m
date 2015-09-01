//
//  AppDelegate.m
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/25.
//  Copyright (c) 2015年 TOMIN. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "MessageListsTableViewController.h"
#import "testViewController.h"

@interface AppDelegate ()
{
    NSDictionary *userInfoNow;
    NSNumber *appDeletegateFlag;
}
@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"AppDelegate-didFinishLaunchingWithOptions");
    //ios本身系統版本判定
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
        acceptAction.identifier = @"Accept";
        acceptAction.title = @"Accept";
        acceptAction.activationMode = UIUserNotificationActivationModeBackground;
        acceptAction.destructive = NO;
        acceptAction.authenticationRequired = NO;
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = @"identifier";
        [category setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
        NSMutableSet *categories = [NSMutableSet set];
        [categories addObject:category];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:categories];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    }else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    //badge 歸零
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    //判斷NSUserDefaults裡的device token若不存在值，設定rootViewController為login畫面
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *mem_id = [defaults objectForKey:@"memID"];
    
    //非會員切換畫面到logingViewController
    if ([mem_id length] == 0) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        HomeViewController *login = [storyBoard instantiateViewControllerWithIdentifier:@"LOGIN"];
        self.window.rootViewController = login;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(returnToZero) name:@"returnToZero" object:nil];
    
    return YES;
}
-(void)returnToZero{
    appDeletegateFlag = [NSNumber numberWithInteger:0];
    NSLog(@"Flag已經歸零");
}
- (void)applicationWillResignActive:(UIApplication *)application {
    
    //找出根目錄來pop指定目標
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    
    //執行pop動作
    [navController popToRootViewControllerAnimated:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"AppDelegate-applicationDidEnterBackground");
    appDeletegateFlag = [NSNumber numberWithInteger:1];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"AppDelegate-applicationWillEnterForeground");
    appDeletegateFlag = [NSNumber numberWithInteger:0];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"RELOADLIST" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    
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
    NSLog(@"AppDelegate-didReceiveRemoteNotification");
    //badge++
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
    
    //儲存要顯示的完整訊息ID
    userInfoNow = [[NSMutableDictionary alloc]initWithDictionary:userInfo[@"aps"]];
    
    
    //將當下收到的userInfo儲存，透過進入前景時，取出message ID 進行內容讀取，並將rootViewController 設定為 MessageDetailViewController
    if (userInfoNow != nil && [appDeletegateFlag isEqualToNumber:[NSNumber numberWithInteger:1]]) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        MessageListsTableViewController *mlTVC = [storyBoard instantiateViewControllerWithIdentifier:@"MSGLIST"];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:@"JudgeHowtoDisplay" object:nil userInfo:@{@"aps":userInfo[@"aps"],@"appDeletegateFlag":appDeletegateFlag}];
        
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        [navigationController.visibleViewController.navigationController pushViewController:mlTVC animated:YES];
    }
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    
    NSLog(@"AppDelegate-handleActionWithIdentifier");
}
@end
