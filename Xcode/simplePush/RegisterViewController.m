//
//  ViewController.m
//  simplePush
//
//  Created by SammaYang on 2015/6/5.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

#import "RegisterViewController.h"
#define hostUrl @"http://192.168.0.12/PHP/"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.inputNameTF.text = self.receiveDictFromHVC[@"userName"];
    self.inputDeviceNameTF.text = self.receiveDictFromHVC[@"deviceName"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setDevieceRegisterInfo{
    //撈取持有者名字
    NSString *memID = [[NSString alloc]init];
    memID = self.inputNameTF.text;
    
    //撈取裝置名稱
    NSString *memName = [[NSString alloc]init];
    memName = self.inputDeviceNameTF.text;
    
    //撈取本機裝置的deviceToken
    //TODO: 這裡會有問題，取不到 NSUserDefaults 內的 @"deviceToken"
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *device_token = [userDefault objectForKey:@"device_Token"];
    NSLog(@"deviceToken is :%@",device_token);
    
    //設定要POST的參數
    NSDictionary *parameters = @{@"memID":memID,@"memName":memName,@"device_token":device_token};
    
    //設定HostURL
    NSURL *url = [NSURL URLWithString:hostUrl];
    
    //設定連線manager
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:url];
    
    //設定manager 願意接收輸入的type
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //將會員資料POST至PHP
    [manager POST:@"DeviceRegister.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //成功的話就執行此block
        NSLog(@"Request Sucessufully!");
        NSLog(@"responseObject :%@",responseObject);
        NSLog(@"使用者:%@ , 持有裝置名:%@ , Device Token:%@",responseObject[@"ret_id"],responseObject[@"ret_user_name"],responseObject[@"return_deviceToken"]);
        
        //將回傳的使用者資料寫入至userDefault
        [userDefault setObject:responseObject[@"ret_id"] forKey:@"memID"];
        [userDefault setObject:responseObject[@"ret_user_name"] forKey:@"memName"];
        [userDefault setObject:responseObject[@"return_deviceToken"] forKey:@"device_token"];
        [userDefault synchronize];
        
        //切換到pushNotificationVC
        if ([responseObject[@"ret_code"] isEqualToString:@"YES"]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"恭喜" message:@"註冊成功" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sucessfullAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self performSegueWithIdentifier:@"pushNotificationVC" sender:nil];
            }];
            [alertController addAction:sucessfullAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }else if ([responseObject[@"ret_code"] isEqualToString:@"NO"]){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"喔不" message:@"註冊失敗" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *failAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSLog(@"%@",responseObject[@"ret_desc"]);
            }];
            [alertController addAction:failAction];
            [self presentViewController:alertController animated:YES completion:nil];

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //成功的話就執行此block
        NSLog(@"Requst Fail!");
    }];
}
- (IBAction)submitButton:(id)sender {
    [self.inputNameTF resignFirstResponder];
    [self.inputDeviceNameTF resignFirstResponder];
    [self setDevieceRegisterInfo];
//    NSLog(@"輸入框內容，userName:%@ 以及deviceName:%@",self.inputNameTF.text,self.inputDeviceNameTF.text);
}
- (IBAction)backToHomeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
