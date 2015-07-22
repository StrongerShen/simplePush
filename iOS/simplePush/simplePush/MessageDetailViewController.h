//
//  MessageDetailViewController.h
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/25.
//  Copyright (c) 2015年 TOMIN. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MessageDetailViewController : UIViewController
@property(strong,nonatomic)NSString *receiveMessageID;
@property(strong,nonatomic)NSString *receiveMessageTitle;
@property(strong,nonatomic)NSMutableDictionary *pushNotiInfo;
@end
