//
//  PushNotificationTableViewController.h
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/18.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

//內建
#import <UIKit/UIKit.h>
#import "CustomPushNotificationTableViewCell.h"

//自定義、第三方
#import "API.h"
#import "MessageDetailViewController.h"
#import "AFNetworking.h"
#import "JDFPeekabooCoordinator.h"

@interface MessageListsTableViewController : UITableViewController
@property(strong,nonatomic)NSMutableArray *userMessageListArray;
@property(strong,nonatomic)NSString *memNo;
@property(strong,nonatomic)NSString *memID;
@property(strong,nonatomic)NSString *memName;
@property(strong,nonatomic)NSString *device_token;
@property(strong,nonatomic)JDFPeekabooCoordinator *scrollCoordinator;

@end
