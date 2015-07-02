//
//  MessageDetailViewController.h
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/25.
//  Copyright (c) 2015年 TOMIN. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MessageDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *fullMessageTextView;
@property(strong,nonatomic)NSString *receiveMessageID;
@end
