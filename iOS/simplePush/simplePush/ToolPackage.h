//
//  ToolPackage.h
//  simpleComm
//
//  Created by SammaYang on 2015/7/10.
//  Copyright (c) 2015年 tomin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToolPackage : NSObject

//回傳MD5加密字串
+(NSString *)transMD5:(NSString *)str;

@end
