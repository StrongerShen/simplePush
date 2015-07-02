//
//  HomeViewController.h
//  simplePush
//
//  Created by GeorgeLuo on 2015/6/25.
//  Copyright (c) 2015年 TOMIN. All rights reserved.
//

//內建framework
#import <UIKit/UIKit.h>

//自定義類別、第三方framework
#import "SeverConfig.h"
#import "AFNetworking.h"

@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *inputNameTF;
@property (weak, nonatomic) IBOutlet UITextField *inputDeviceNameTF;

@end
