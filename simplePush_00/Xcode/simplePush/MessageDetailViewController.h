//
//  MessageDetailViewController.h
//  simplePush
//
//  Created by 羅祐昌 on 2015/6/23.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

//內建
#import <UIKit/UIKit.h>

//自定義、第三方
#import "AFNetworking.h"
#import "API.h"
#import "JDFPeekabooCoordinator.h"

@interface MessageDetailViewController : UIViewController
@property(strong,nonatomic)NSString *receiveMessageID;
@property (weak, nonatomic) IBOutlet UITextView *fullMessageTextView;
@property(strong,nonatomic)JDFPeekabooCoordinator *scrollCoordinator;
@end
