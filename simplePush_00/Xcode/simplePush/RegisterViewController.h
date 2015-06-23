//
//  ViewController.h
//  simplePush
//
//  Created by SammaYang on 2015/6/5.
//  Copyright (c) 2015年 Samma.Yang. All rights reserved.
//

//內建
#import <UIKit/UIKit.h>

//自定義、第三方
#import "AFNetworking.h"
#import "API.h"

@interface RegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *inputNameTF;
@property (weak, nonatomic) IBOutlet UITextField *inputDeviceNameTF;
@property (strong,nonatomic) NSDictionary *receiveDictFromHVC;
@end

