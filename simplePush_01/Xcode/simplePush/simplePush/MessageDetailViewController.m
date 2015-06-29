//
//  MessageDetailViewController.m
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/25.
//  Copyright (c) 2015年 TOMIN. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "SeverConfig.h"
#import "AFNetworking.h"

@interface MessageDetailViewController ()

@end

@implementation MessageDetailViewController
@synthesize receiveMessageID,fullMessageTextView;

- (void)viewDidLoad {
    [super viewDidLoad];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    //設定 navigationBar、title、barItem 顏色
    UIColor *navgationBarColor = [UIColor colorWithRed:0.497 green:0.759 blue:0.175 alpha:1.000];
    self.navigationController.navigationBar.barTintColor = navgationBarColor; //改變 Bar 顏色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.081 green:0.437 blue:0.778 alpha:1.000]; //改變 BarItem 的顏色
    
    // 改變 title 顏色
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20.0];
    titleView.textColor = [UIColor whiteColor]; // Your color here
    titleView.text = @"訊息內容";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
    
    [self getUserMessageListArray];
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
-(void)getUserMessageListArray{
    
    //設定要POST的參數
    NSDictionary *parameters = @{@"news_id":receiveMessageID};
    
    //設定HostURL
    NSURL *url = [NSURL URLWithString:hostUrl];
    
    //設定連線manager
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:url];
    
    //設定manager 願意接收輸入的type
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //將會員資料POST至PHP
    [manager POST:@"responseFullMsg.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *ok = [NSNumber numberWithInt:0];
        NSNumber *fail = [NSNumber numberWithInt:1];
        
        //根據errCode判定是否抓到完整訊息
        if (responseObject[@"fullMsg"] != nil && [responseObject[@"errCode"] isEqualToNumber:ok]) {
            fullMessageTextView.text = responseObject[@"fullMsg"];
        }
        else if(responseObject[@"fullMsg"] == nil && [responseObject[@"errCode"] isEqualToNumber:fail]){
            NSLog(@"錯誤為:%@",responseObject[@"errMsg"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //成功的話就執行此block
        NSLog(@"Requst Fail!");
    }];
}
@end
