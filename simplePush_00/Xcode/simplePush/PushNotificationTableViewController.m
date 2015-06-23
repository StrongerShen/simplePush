//
//  PushNotificationTableViewController.m
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/18.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

#import "PushNotificationTableViewController.h"
#define hostUrl @"http://192.168.0.12/PHP/"
@interface PushNotificationTableViewController ()
@end
@implementation PushNotificationTableViewController
@synthesize memID,memName,device_token,userMessageListArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //將使用者的ID、裝置名稱、DT從userDefault撈出
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    memID = [userDefault objectForKey:@"memID"];
    memName = [userDefault objectForKey:@"memName"];
    device_token = [userDefault objectForKey:@"device_token"];
    NSLog(@"在RegisterViewController根據回傳資料確實有寫入到userDefault,memID:%@、memName:%@、device_token:%@",memID,memName,device_token);
    
    userMessageListArray = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return userMessageListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomPushNotificationTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:@"CustomPushNotificationTableViewCell" forIndexPath:indexPath];
    customCell.messageLabel.text = userMessageListArray[indexPath.row][@"sendTime"];
    customCell.timeLabel.text = userMessageListArray[indexPath.row][@"preMsg"];
    NSString *tag = userMessageListArray[indexPath.row][@"haveRead"];
    if (tag != nil && [tag isEqualToString:@"0"]) {
        customCell.readOrNotImageView.image = [UIImage imageNamed:@"Unread"];
    }else if (tag != nil && [tag isEqualToString:@"1"]){
        customCell.readOrNotImageView.image = [UIImage imageNamed:@"Read"];
    }else{
        NSLog(@"出現問題，沒有辦法判定Tag");
    }
    
    return customCell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark -- 透過上傳使用者的ID，根據這個ID去撈訊息list回來、訊息的Tag(撈出判斷訊息讀取否)、訊息的identiFiler
-(void)getUserMessageListArray{
    
    //設定要POST的參數
    NSDictionary *parameters = @{@"member_id":memID};
    
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
        
        //取得訊息清單、發送時間、訊息大綱、已讀或未讀Tag
        userMessageListArray = responseObject[@"content"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //成功的話就執行此block
        NSLog(@"Requst Fail!");
    }];
}
@end
