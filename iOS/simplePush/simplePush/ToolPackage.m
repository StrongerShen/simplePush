//
//  ToolPackage.m
//  simpleComm
//
//  Created by SammaYang on 2015/7/10.
//  Copyright (c) 2015年 tomin. All rights reserved.
//

#import "ToolPackage.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ToolPackage

+(NSString *)transMD5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *resultString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02x",digest[i]];
    }
    return resultString;
}


@end
