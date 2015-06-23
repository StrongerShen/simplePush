//
//  HomeViewController.h
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/18.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

//內建
#import <UIKit/UIKit.h>

//自定義、第三方
#import "API.h"
#import "AFNetworking.h"
@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *inputNameTF;
@property (weak, nonatomic) IBOutlet UITextField *inputDeviceNameTF;
@end
