//
//  MessageDetailViewController.m
//  simplePush
//
//  Created by 羅祐昌 on 2015/6/23.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

#import "MessageDetailViewController.h"
@interface MessageDetailViewController ()

@end

@implementation MessageDetailViewController
@synthesize receiveMessageID,fullMessageTextView,scrollCoordinator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"確實收到由cell傳送過來的MessageID:%@",receiveMessageID);
    [self getUserMessageListArray];
    
    //設定ToolBar、NavigationBar顏色
    UIColor *blueColour = [UIColor colorWithRed:0.248 green:0.753 blue:0.857 alpha:1.000];
//    self.navigationController.toolbarHidden = YES;
    self.navigationController.navigationBar.barTintColor = blueColour;  //改變Bar顏色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];   //改變BarItem顏色
    
    //滾動螢幕時觸發隱藏ToolBar、NavigationBar
    scrollCoordinator = [[JDFPeekabooCoordinator alloc] init];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [scrollCoordinator enable];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    [scrollCoordinator disable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

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
        
        //成功的話就執行此block
        NSLog(@"Request Sucessufully!");
        NSLog(@"responseObject :%@",responseObject);
        
        NSNumber *ok = [NSNumber numberWithInt:0];
        NSNumber *fail = [NSNumber numberWithInt:1];
        //根據errCode判定是否抓到完整訊息
        if (responseObject[@"fullMsg"] != nil && [responseObject[@"errCode"] isEqualToNumber:ok]) {
            fullMessageTextView.text = responseObject[@"fullMsg"];
        }else if(responseObject[@"fullMsg"] == nil && [responseObject[@"errCode"] isEqualToNumber:fail]){
            NSLog(@"錯誤為:%@",responseObject[@"errMsg"]);
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
    // Pass the selected object to the new view controller.
}
*/

@end
