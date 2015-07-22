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
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *fullMessageTextView;
@end

@implementation MessageDetailViewController
@synthesize receiveMessageID,fullMessageTextView,titleLabel,receiveMessageTitle,pushNotiInfo,MessageDetailViewControllerTag;

- (void)viewDidLoad {
    
    NSLog(@"你執行了MDVC的viewDidLoad");
    [super viewDidLoad];
    if (MessageDetailViewControllerTag == 0) {
        [self getFullMessage];
    }else if(MessageDetailViewControllerTag == 1){
        [self clickPushNotificationToGetFullMessage];
        MessageDetailViewControllerTag = 0;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    NSLog(@"你執行了MDVC的viewWillAppear");
    
    //設定 navigationBar、title、barItem 顏色
    UIColor *navgationBarColor = [UIColor colorWithRed:0.497 green:0.759 blue:0.175 alpha:1.000];
    self.navigationController.navigationBar.barTintColor = navgationBarColor;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.081 green:0.437 blue:0.778 alpha:1.000];
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    // 改變 title 顏色
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20.0];
    titleView.textColor = [UIColor whiteColor]; // Your color here
    titleView.text = @"訊息內容";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getFullMessage{
    
    NSLog(@"你執行了MDVC的getFullMessage");
    
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
            titleLabel.text = receiveMessageTitle;
            
            receiveMessageID = [NSString new];
            receiveMessageTitle = [NSString new];
        }
        else if(responseObject[@"fullMsg"] == nil && [responseObject[@"errCode"] isEqualToNumber:fail]){
            NSLog(@"錯誤為:%@",responseObject[@"errMsg"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //成功的話就執行此block
        NSLog(@"Requst Fail!");
    }];
}
-(void)clickPushNotificationToGetFullMessage{
    
    NSLog(@"你執行了MDVC的clickPushNotificationToGetFullMessage");
    
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
            titleLabel.text = receiveMessageTitle;
            
            receiveMessageID = [NSString new];
            receiveMessageTitle = [NSString new];
            MessageDetailViewControllerTag = 0;
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
