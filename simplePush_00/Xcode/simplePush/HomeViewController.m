//
//  HomeViewController.m
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/18.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

#import "HomeViewController.h"
#define hostUrl @"http://192.168.0.12/PHP/"
@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setDeviceTokenToUserDefault:) name:@"passDT" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setDeviceTokenToUserDefault:(NSNotification *)notification{
    NSDictionary *receiveDictionary = notification.userInfo;
    NSLog(@"收到從AppDelegate傳送過來的DT為:%@",receiveDictionary[@"device_Token"]);
    
    //將收到的deviceToken存入userDefault
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:receiveDictionary[@"device_Token"] forKey:@"device_Token"];
    [userDefault synchronize];
}

- (IBAction)submitButton:(id)sender {
    //收鍵盤
    [self.inputNameTF resignFirstResponder];
    [self.inputDeviceNameTF resignFirstResponder];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *memID = [userDefault objectForKey:@"memID"];
    NSString *memName = [userDefault objectForKey:@"memName"];
    NSString *device_token = [userDefault objectForKey:@"device_token"];
    
    //是會員
    if (memID != nil && [memID isEqual:self.inputNameTF.text] && memName != nil && [memName isEqual:self.inputDeviceNameTF.text] && device_token != nil) {
        
        [self performSegueWithIdentifier:@"toPushNotificationVC" sender:nil];
    }
    
    //不是會員
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"登入錯誤" message:@"你不是會員" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *registerAction = [UIAlertAction actionWithTitle:@"前往註冊" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"toRegisterViewController" sender:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"回到首頁" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //
        }];
        [alertController addAction:registerAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    NSDictionary *passDictionary = @{@"userName":self.inputNameTF.text,@"deviceName":self.inputDeviceNameTF.text};
    RegisterViewController *rvc = [segue destinationViewController];
    rvc.receiveDictFromHVC = passDictionary;
}


@end
