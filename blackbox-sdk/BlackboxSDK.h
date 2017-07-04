//  BlackboxSDK.m
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <Foundation/Foundation.h>

@interface BlackboxSDK : NSObject

+ (instancetype)sharedSDK;

- (void)recordRevenue:(double)value withCurrency:(NSString *)currency;

@end

OBJC_EXTERN NSString *BBPCurrencyGBP;
OBJC_EXTERN NSString *BBPCurrencyUSD;
OBJC_EXTERN NSString *BBPCurrencyAUD;
OBJC_EXTERN NSString *BBPCurrencyNZD;


@interface BlackboxSDK (BlackboxSDKUnavailable)
- (instancetype)init OBJC_UNAVAILABLE("Use [BlackboxSDK sharedSDK], not [BlackboxSDK new] or [[BlackboxSDK alloc] init]");
@end
