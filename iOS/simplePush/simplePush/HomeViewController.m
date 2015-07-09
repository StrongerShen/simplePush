//
//  HomeViewController.m
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/25.
//  Copyright (c) 2015年 TOMIN. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
{
    NSDictionary *parameters;
    NSUserDefaults *userDefault;
}
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@end

@implementation HomeViewController
@synthesize inputNameTF,inputDeviceNameTF,submitBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userDefault = [NSUserDefaults standardUserDefaults];
    
    //設定按鈕外觀
    submitBtn.layer.cornerRadius = 5;
    submitBtn.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getParameter
{
    //撈取持有者名字
    NSString *memID = [[NSString alloc]init];
    memID = inputNameTF.text;
    
    //撈取裝置名稱
    NSString *memName = [[NSString alloc]init];
    memName = inputDeviceNameTF.text;
    
    //撈取本機裝置的deviceToken
    NSString *device_token = [userDefault objectForKey:@"device_token"];
    
    //設定要POST的參數
    parameters = @{@"memID":memID,@"memName":memName,@"device_token":device_token,@"device_type":@"0"};
}

- (IBAction)submitButton:(id)sender {
    //收鍵盤
    [inputNameTF resignFirstResponder];
    [inputDeviceNameTF resignFirstResponder];
    
    //step1.取得要pass給DeviceRegister.php的參數
    [self getParameter];
    
    //設定HostURL
    NSURL *url = [NSURL URLWithString:hostUrl];
    
    //設定連線manager
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:url];
    
    //設定manager 願意接收輸入的type
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //將會員資料上傳比對是否已經存在，若不存在就新增
    [manager POST:@"DeviceRegister.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
                
                [self performSegueWithIdentifier:@"linkMessage" sender:nil];

            }];
            
            [alertController addAction:sucessfullAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else if ([responseObject[@"ret_code"] isEqualToString:@"NO"]){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"喔不" message:@"註冊失敗" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *failAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSLog(@"DT已經存在:%@",responseObject[@"ret_desc"]);
                
                //將回傳的使用者資料寫入至userDefault
                [userDefault setObject:responseObject[@"user_id"] forKey:@"memNo"];
                [userDefault setObject:responseObject[@"user_name"] forKey:@"memID"];
                [userDefault setObject:responseObject[@"device_name"] forKey:@"memName"];
                [userDefault setObject:responseObject[@"device_token"] forKey:@"device_token"];
                [userDefault synchronize];
                
                [self performSegueWithIdentifier:@"linkMessage" sender:nil];
                
            }];
            [alertController addAction:failAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //成功的話就執行此block
        NSLog(@"Requst Fail!");
    }];
}

@end
