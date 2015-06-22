//
//  CustomPushNotificationTableViewCell.m
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/22.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

#import "CustomPushNotificationTableViewCell.h"

@implementation CustomPushNotificationTableViewCell
@synthesize messageLabel,timeLabel,readOrNotImageView;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
