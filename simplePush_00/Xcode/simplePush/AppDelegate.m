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
    UIAlertView *errorAlterView=[[UIAlertView alloc]initWithTitle:@"title"
                                                          message:@"applicationWillEnterForeground"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil, nil];
    
    [errorAlterView show];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"Device token: %@", newToken);
    
    //判斷手機上的Device Token是否存在(NSUserDefaults)
    
    //處理使用者帳號、名稱、密碼...等資訊
    NSString *memID = @"Stronger2";
    NSString *memName = @"Stronger iPad Air 2";
    
    //將Device Token與user資訊傳到provider server
    //產生網址物件
    NSURL *url = [NSURL URLWithString:kJSON];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"device_token=%@&memID=%@&memName=%@",newToken, memID, memName];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    //多執行緒的queue => 背景執行
    NSOperationQueue *queue = [[ NSOperationQueue alloc] init ];
    //建立連線，以非同步的方式
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
     //資料連結後執行，並傳入response、data、error
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if ([data length] > 0 && connectionError == nil) {
                                   //解碼 => 把遠端的資料解開變成Dictionary，Serialization => 轉換二進制資料
                                   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                                        options:NSJSONReadingAllowFragments
                                                                                          error:nil];
                                   NSLog(@"%@", dict);
                                   if ([dict[@"ret_code"] isEqualToString:@"YES"]) {
                                       NSLog(@"更新Device Token完成");
                                       //因為是放到queue執行，要更新到畫面上的(拉回前景),用以下方式
                                       /*
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                        [self showAlertView:@"資料下載" andMessaage:@"下載完成"];
                                        });
                                        */
                                   } else {
                                       NSLog(@"Device Token已經存在");
                                   }
                               } else if ([data length] == 0 && connectionError == nil) {
                                   NSLog(@"error1");
                               } else if (connectionError != nil) {
                                   NSLog(@"error2");
                               }
                               
                           }];

    
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
