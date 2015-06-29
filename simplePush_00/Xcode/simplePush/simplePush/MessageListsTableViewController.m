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
    
    //將使用者的ID、裝置名稱、DT從userDefault撈出
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    memNo = [userDefault objectForKey:@"memNo"];
    memID = [userDefault objectForKey:@"memID"];
    memName = [userDefault objectForKey:@"memName"];
    device_token = [userDefault objectForKey:@"device_token"];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self getUserMessageListArray];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
    else if (tag != nil && [tag isEqualToString:@"1"]){
        customCell.readOrNotImageView.image = [UIImage imageNamed:@"Read"];
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
    [self performSegueWithIdentifier:@"toFullMessage" sender:newsId];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MessageDetailViewController *mdvc = [segue destinationViewController];
    mdvc.receiveMessageID = sender;
}
- (IBAction)refreshBtn:(id)sender {
    [self getUserMessageListArray];
}

#pragma mark -- 透過上傳使用者的ID，根據這個ID去撈訊息list回來、訊息的Tag(撈出判斷訊息讀取否)、訊息的identiFiler
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Requst Fail!");
    }];
}

@end
