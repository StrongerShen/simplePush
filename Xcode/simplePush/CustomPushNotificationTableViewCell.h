//
//  CustomPushNotificationTableViewCell.h
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/22.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPushNotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *readOrNotImageView;
@end

