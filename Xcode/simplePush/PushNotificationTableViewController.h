//
//  PushNotificationTableViewController.h
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/18.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPushNotificationTableViewCell.h"

#import "AFNetworking.h"
@interface PushNotificationTableViewController : UITableViewController
@property(strong,nonatomic)NSMutableArray *userMessageListArray;
@property(strong,nonatomic)NSString *memID;
@property(strong,nonatomic)NSString *memName;
@property(strong,nonatomic)NSString *device_token;

@end
