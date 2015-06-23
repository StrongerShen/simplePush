//
//  HomeViewController.m
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/18.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

#import "HomeViewController.h"
@interface HomeViewController ()

@end

@implementation HomeViewController


- (IBAction)CloseKBD:(id)sender {
}

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
    NSDictionary *receiveDict = notification.userInfo;
    NSLog(@"收到從AppDelegate傳送過來的DT為:%@",receiveDict[@"device_token"]);
    
    //將收到的deviceToken存入userDefault
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:receiveDict[@"device_token"] forKey:@"device_token"];
    [userDefault synchronize];    
}
- (IBAction)submitButton:(id)sender{
    
    //收鍵盤
    [self.inputNameTF resignFirstResponder];
    [self.inputDeviceNameTF resignFirstResponder];
    
    //撈取持有者名字
    NSString *memID = [[NSString alloc]init];
    memID = self.inputNameTF.text;
    
    //撈取裝置名稱
    NSString *memName = [[NSString alloc]init];
    memName = self.inputDeviceNameTF.text;
    
    //撈取本機裝置的deviceToken
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *device_token = [userDefault objectForKey:@"device_token"];
    NSLog(@"deviceToken is :%@",device_token);
    
    //設定要POST的參數
    NSDictionary *parameters = @{@"memID":memID,@"memName":memName,@"device_token":device_token};
    
    //設定HostURL
    NSURL *url = [NSURL URLWithString:hostUrl];
    
    //設定連線manager
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:url];
    
    //設定manager 願意接收輸入的type
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //將會員資料上傳比對是否已經存在，若不存在就新增
    [manager POST:@"DeviceRegister.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //成功的話就執行此block
        NSLog(@"Request Sucessufully!");
        NSLog(@"responseObject :%@",responseObject);
        NSLog(@"使用者編號:%@ , 使用者名字:%@ , 使用者持有裝置名:%@ , Device Token:%@",responseObject[@"user_id"],responseObject[@"user_name"],responseObject[@"device_name"],responseObject[@"device_token"]);
        
        //切換到pushNotificationVC
        if ([responseObject[@"ret_code"] isEqualToString:@"YES"]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"恭喜" message:@"註冊成功" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sucessfullAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

                //將回傳的使用者資料寫入至userDefault
                [userDefault setObject:responseObject[@"user_id"] forKey:@"memNo"];
                [userDefault setObject:responseObject[@"user_name"] forKey:@"memID"];
                [userDefault setObject:responseObject[@"device_name"] forKey:@"memName"];
                [userDefault setObject:responseObject[@"device_token"] forKey:@"device_token"];
                [userDefault synchronize];
                
                [self performSegueWithIdentifier:@"pushNotificationVC" sender:nil];
            }];
            
            [alertController addAction:sucessfullAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else if ([responseObject[@"ret_code"] isEqualToString:@"NO"]){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"喔不" message:@"註冊失敗" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *failAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSLog(@"DT已經存在,請更換其他裝置:%@",responseObject[@"ret_desc"]);
            }];
            [alertController addAction:failAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //成功的話就執行此block
        NSLog(@"Requst Fail!");
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
}
*/

@end
