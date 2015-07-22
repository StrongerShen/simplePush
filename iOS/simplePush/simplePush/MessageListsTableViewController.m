//
//  MessageListsTableViewController.m
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/25.
//  Copyright (c) 2015年 TOMIN. All rights reserved.
//

#import "MessageListsTableViewController.h"
#import "MessageDetailViewController.h"

@interface MessageListsTableViewController ()
@property(strong,nonatomic)NSMutableArray *userMessageListArray;
@property(strong,nonatomic)NSString *memNo;
@property(strong,nonatomic)NSString *memID;
@property(strong,nonatomic)NSString *memName;
@property(strong,nonatomic)NSString *device_token;
@end

@implementation MessageListsTableViewController
@synthesize memNo,memID,memName,device_token,userMessageListArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(getUserMessageListArray) name:@"RELOADLIST" object:nil];
    
    //將使用者的 ID、裝置名稱、DT，從 userDefault 撈出
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    memNo = [userDefault objectForKey:@"memNo"];
    memID = [userDefault objectForKey:@"memID"];
    memName = [userDefault objectForKey:@"memName"];
    device_token = [userDefault objectForKey:@"device_token"];
    
    //設定 navigationBar、title、barItem 顏色
    UIColor *navgationBarColor = [UIColor colorWithRed:0.561 green:0.765 blue:0.122 alpha:1.000];
    self.navigationController.navigationBar.barTintColor = navgationBarColor; //改變 Bar 顏色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor]; //改變 BarItem 的顏色
    
    // 改變 title 顏色
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:22.0];
    titleView.textColor = [UIColor whiteColor]; // Your color here
    titleView.text = @"即時新聞";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self getUserMessageListArray];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//透過上傳使用者的ID，根據這個ID去撈訊息list回來、訊息的Tag(撈出判斷訊息讀取否)、訊息的identiFiler
-(void)getUserMessageListArray{
    
    userMessageListArray = [NSMutableArray new];
    
    //設定要POST的參數
    NSDictionary *parameters = @{@"member_id":memID};
    
    //設定HostURL
    NSURL *url = [NSURL URLWithString:hostUrl];
    
    //設定連線manager
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:url];
    
    //設定manager 願意接收輸入的type
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //將會員資料POST至PHP
    [manager POST:@"getMsgList.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //取得訊息清單、發送時間、訊息大綱、已讀或未讀Tag
        userMessageListArray = [NSMutableArray arrayWithArray:responseObject[@"content"]];
        [self.tableView reloadData];
        
        //設定 badge: 最新的未讀訊息筆數
        int badge=0;
        for (NSDictionary *temp in userMessageListArray) {
            if ([temp[@"haveRead"] isEqualToString:@"0"] ) {
                badge++;
            }
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Requst Fail!");
    }];
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
    customCell.messageLabel.text = userMessageListArray[indexPath.row][@"preMsg"];
    customCell.timeLabel.text = userMessageListArray[indexPath.row][@"sendTime"];
    NSString *tag = userMessageListArray[indexPath.row][@"haveRead"];
    if (tag != nil && [tag isEqualToString:@"0"]) {
        customCell.readMessageLabel.text = @"未讀";
        customCell.readMessageLabel.backgroundColor = [UIColor colorWithRed:0.561 green:0.765 blue:0.122 alpha:1.000];
    }
    else if (tag != nil && [tag isEqualToString:@"1"]){
        customCell.readMessageLabel.text = @"已讀";
        customCell.readMessageLabel.backgroundColor = [UIColor colorWithRed:0.788 green:0.792 blue:0.792 alpha:1.000];
    }
    else{
        NSLog(@"出現問題，沒有辦法判定Tag");
    }
    
    return customCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //badge--
    [UIApplication sharedApplication].applicationIconBadgeNumber--;
    
    NSString *newsId = [NSString stringWithFormat:@"%@",userMessageListArray[indexPath.row][@"newsId"]];
    NSString *newsTitle = [NSString stringWithFormat:@"%@",userMessageListArray[indexPath.row][@"preMsg"]];
    NSArray *pass = [[NSArray alloc]initWithObjects:newsId,newsTitle, nil];
    [self performSegueWithIdentifier:@"toFullMessage" sender:pass];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //取出要刪除的message ID
        NSString *newsID = userMessageListArray[indexPath.row][@"newsId"];
        
        //post
        NSDictionary *parameters = @{@"news_id":newsID};
        
        //設定HostURL
        NSURL *url = [NSURL URLWithString:hostUrl];
        
        //設定連線manager
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:url];
        
        //設定manager 願意接收輸入的type
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        //將會員資料POST至PHP
        [manager POST:@"delMsg.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"處理結果:%@ ,說明:%@",responseObject[@"ret_code"],responseObject[@"ret_desc"]);
            if ([responseObject[@"ret_code"]isEqualToString:@"YES"]) {
                //刪除陣列內資料
                [userMessageListArray removeObjectAtIndex:indexPath.row];
                
                //移除列
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                //重整
                [self.tableView reloadData];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"發生錯誤:%@",error);
        }];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }

}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MessageDetailViewController *mdvc = [segue destinationViewController];
    mdvc.receiveMessageID = sender[0];
    mdvc.receiveMessageTitle = sender[1];
}

@end
