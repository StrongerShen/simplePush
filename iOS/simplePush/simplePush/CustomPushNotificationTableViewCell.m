//
//  CustomPushNotificationTableViewCell.m
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/25.
//  Copyright (c) 2015年 TOMIN. All rights reserved.
//

#import "CustomPushNotificationTableViewCell.h"

@implementation CustomPushNotificationTableViewCell
@synthesize readOrNotImageView;
- (void)awakeFromNib {
    // Initialization code
    readOrNotImageView.layer.cornerRadius = 5;
    readOrNotImageView.clipsToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
