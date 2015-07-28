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
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property(strong,nonatomic)NSNotificationCenter *notificationCenter;
@end

@implementation MessageDetailViewController
@synthesize receiveNewsId,receiveNewsTitle,fullMessageTextView,titleLabel,timeLabel,pushNotiInfo,MessageDetailViewControllerTag,notificationCenter;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"MessageDetailViewController-viewDidLoad");
    notificationCenter = [NSNotificationCenter defaultCenter];
    [self getFullMessage];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"MessageDetailViewController-viewWillAppear");
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
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSLog(@"MessageDetailViewController-viewDidAppear");
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    NSLog(@"MessageDetailViewController-viewDidDisappear");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)getFullMessage{
    
    //設定要POST的參數
    NSDictionary *parameters = @{@"news_id":receiveNewsId};
    
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
            titleLabel.text = responseObject[@"title"];
            timeLabel.text = responseObject[@"sendTime"];
            fullMessageTextView.text = responseObject[@"fullMsg"];
            [notificationCenter postNotificationName:@"returnToZero" object:nil];
        }else if(responseObject[@"fullMsg"] == nil && [responseObject[@"errCode"] isEqualToNumber:fail]){
            NSLog(@"錯誤為:%@",responseObject[@"errMsg"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //成功的話就執行此block
        NSLog(@"Requst Fail!");
    }];
}
@end
