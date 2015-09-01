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
@property(strong,nonatomic)NSNumber *MessageListsTableViewControllerFlag;
@property(strong,nonatomic)NSString *memNo;
@property(strong,nonatomic)NSString *memID;
@property(strong,nonatomic)NSString *memName;
@property(strong,nonatomic)NSString *device_token;
@end

@implementation MessageListsTableViewController
@synthesize memNo,memID,memName,device_token,userMessageListArray = _userMessageListArray,MessageListsTableViewControllerFlag;

- (void)setUserMessageListArray:(NSMutableArray *)userMessageListArray
{
    _userMessageListArray = userMessageListArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"MessageListsTableViewController-viewDidLoad");
    //建立 NotificationCenter
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(receivePushNotificationJudgeHowtoDisplay:) name:@"JudgeHowtoDisplay" object:nil];
    
    //set user's profile
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    memNo = [userDefault objectForKey:@"memNo"];
    memID = [userDefault objectForKey:@"memID"];
    memName = [userDefault objectForKey:@"memName"];
    device_token = [userDefault objectForKey:@"device_token"];
    
    //set navigationBar、barItem color
    UIColor *navgationBarColor = [UIColor colorWithRed:0.561 green:0.765 blue:0.122 alpha:1.000];
    self.navigationController.navigationBar.barTintColor = navgationBarColor;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //set navigationBar title color
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:22.0];
    titleView.textColor = [UIColor whiteColor];
    titleView.text = @"即時新聞";
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"MessageListsTableViewController-viewWillAppear");
    
    [self receivePushNotificationJudgeHowtoDisplay:nil];
    [self.tableView reloadData];
}
//- (void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:YES];
//    NSLog(@"MessageListsTableViewController-viewDidAppear");
//}
//- (void)viewWillDisappear:(BOOL)animated{
//    NSLog(@"MessageListsTableViewController-viewWillDisappear");
//}
//- (void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:YES];
//    NSLog(@"MessageListsTableViewController-viewDidDisappear");
//}
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}

- (void)receivePushNotificationJudgeHowtoDisplay:(NSNotification *)notification{
    
    self.userMessageListArray = [NSMutableArray new];
    
    //設定POST參數
    NSDictionary *parameters = @{@"member_id":memID};
    NSURL *url = [NSURL URLWithString:hostUrl];
    
    //設定連線 manager
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:url];
    
    //設定 manager 願意接收輸入的type
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //將 memID POST 至 PHP
    [manager POST:@"getMsgList.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //取得訊息清單、發送時間、訊息大綱、已讀或未讀Tag
        self.userMessageListArray = [NSMutableArray arrayWithArray:responseObject[@"content"]];
//        [self.tableView reloadData];
        
        //設定 badge: 最新的未讀訊息筆數
        int badge = 0;
        for (NSDictionary *temp in self.userMessageListArray) {
            if ([temp[@"haveRead"] isEqualToString:@"0"] ) {
                badge++;
            }
        }
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
        
        NSDictionary *fromAppDelegate = [notification userInfo];
        MessageListsTableViewControllerFlag = fromAppDelegate[@"appDeletegateFlag"];
        if ([MessageListsTableViewControllerFlag isEqualToNumber:[NSNumber numberWithInteger:1]]) {
            [self performSegueWithIdentifier:@"toFullMessage" sender:fromAppDelegate[@"aps"][@"newsId"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"未取得訊息清單，Request Fail !");
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userMessageListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomPushNotificationTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:@"CustomPushNotificationTableViewCell" forIndexPath:indexPath];
    customCell.messageLabel.text = self.userMessageListArray[indexPath.row][@"preMsg"];
    customCell.timeLabel.text = self.userMessageListArray[indexPath.row][@"sendTime"];
    NSString *tag = self.userMessageListArray[indexPath.row][@"haveRead"];
    if (tag != nil && [tag isEqualToString:@"0"]) {
        customCell.readMessageLabel.text = @"未讀";
        customCell.readMessageLabel.textColor = [UIColor whiteColor];
        customCell.readMessageLabel.backgroundColor = [UIColor colorWithRed:0.561 green:0.765 blue:0.122 alpha:1.000];
    }
    else if (tag != nil && [tag isEqualToString:@"1"]){
        UIColor *grayColor = [UIColor colorWithRed:0.788 green:0.792 blue:0.792 alpha:1.000];
        customCell.readMessageLabel.text = @"已讀";
        customCell.readMessageLabel.textColor = grayColor;
        customCell.readMessageLabel.backgroundColor = [UIColor whiteColor];
        customCell.readMessageLabel.layer.borderWidth = 1;
        customCell.readMessageLabel.layer.borderColor = grayColor.CGColor;
    }
    else{
        NSLog(@"出現問題，沒有辦法判定Tag");
    }
    
    return customCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //badge--
    [UIApplication sharedApplication].applicationIconBadgeNumber--;
    
    NSString *newsId = [NSString stringWithFormat:@"%@",self.userMessageListArray[indexPath.row][@"newsId"]];
    //    NSString *newsTitle = [NSString stringWithFormat:@"%@",userMessageListArray[indexPath.row][@"preMsg"]];
    //    NSArray *pass = [[NSArray alloc]initWithObjects:newsId,newsTitle, nil];
    //    [self performSegueWithIdentifier:@"toFullMessage" sender:pass];
    [self performSegueWithIdentifier:@"toFullMessage" sender:newsId];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {    
        //取出要刪除的message ID
        NSString *newsID = self.userMessageListArray[indexPath.row][@"newsId"];
        
        //post
        NSDictionary *parameters = @{@"news_id":newsID};
        
        //設定HostURL
        NSURL *url = [NSURL URLWithString:hostUrl];
        
        //設定連線manager
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:url];
        
        //設定manager 願意接收輸入的type
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        //將會員資料POST至PHP
        [manager POST:@"delMsg.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSLog(@"處理結果:%@ ,說明:%@",responseObject[@"ret_code"],responseObject[@"ret_desc"]);
            if ([responseObject[@"ret_code"]isEqualToString:@"YES"])
            {
                //刪除陣列內資料
                [self.userMessageListArray removeObjectAtIndex:indexPath.row];
                
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
             NSLog(@"發生錯誤:%@",error);
        }];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MessageDetailViewController *mdvc = [segue destinationViewController];
    mdvc.receiveNewsId = sender;
    //    mdvc.receiveNewsId = sender[0];
    //    mdvc.receiveNewsTitle = sender[1];
}

@end
