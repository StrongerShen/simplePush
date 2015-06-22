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
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *device_token = [userDefault objectForKey:@"deviceToken"];
    NSLog(@"deviceToken is :%@",device_token);
    
    //設定要POST的參數
    NSDictionary *parameters = @{@"memID":memID,@"memName":memName,@"device_token":device_token};
    
    //設定Host url
    NSURL *url = [NSURL URLWithString:hostUrl];
    
    //設定manager
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:url];
    
    //設定manager 願意接收輸入的type
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //POST
    [manager POST:@"DeviceRegister.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //成功的話就執行此block
        NSLog(@"Request Sucessufully!");
        NSLog(@"responseObject :%@",responseObject);
        NSLog(@"使用者:%@ , 持有裝置名:%@ , Device Token:%@",responseObject[@"ret_id"],responseObject[@"ret_user_name"],responseObject[@"return_deviceToken"]);
        
        //切換到pushNotificationVC
        if (responseObject) {
            [self performSegueWithIdentifier:@"pushNotificationVC" sender:nil];
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
