//  BlackboxSDK.m
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

#import "BlackboxSDK.h"
#import "BBPClient.h"
#import "BBPEvent.h"
#import "Util.h"

@implementation BlackboxSDK {
    BBPClient *_client;
}

#define BLACKBOX_TOKEN_ID @"BBPClientID"
#define HAS_LAUNCHED_KEY @"BBPApplicationHasLaunched"

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:[self sharedSDK]
                                             selector:@selector(handleApplicationLaunched:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];

    [[ADClient sharedClient] requestAttributionDetailsWithBlock:^(NSDictionary *attributionDetails, NSError *error) {
        if (attributionDetails[@"iad-attribution"] && attributionDetails[@"iad-campaign-id"]) {
            [[self sharedSDK] handleAttributionDetectedForCampaign:attributionDetails[@"iad-campaign-id"]
                                                            withKeyword:attributionDetails[@"iad-keyword"]];
        }
    }];
}

+ (instancetype)sharedSDK {
    static BlackboxSDK *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];

        if (info[BLACKBOX_TOKEN_ID]) {
            instance = [[self alloc] initWithToken:info[BLACKBOX_TOKEN_ID]];

        } else {
            LogError(@"BBPClientID is not set in your Info.plist. Blackbox Platform will not receive attribution events until this is added.");
        }
    });

    return instance;
}

- (instancetype)init {
    [[NSException exceptionWithName:@"BBPError" reason:@"Use [BlackboxSDK sharedSDK], not [BlackboxSDK new] or [[BlackboxSDK alloc] init]" userInfo:nil] raise];
    return nil;
}

- (instancetype)initWithToken:(NSString *)token {
    if (self = [super init]) {
        _client = [[BBPClient alloc] initWithToken:token];
    }
    
    return self;
}

- (void)handleApplicationLaunched:(id)_ {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HAS_LAUNCHED_KEY]) {
        [_client dispatchEvent:[[BBPEvent alloc] initWithName:@"launch"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HAS_LAUNCHED_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [_client dispatchEvent:[[BBPEvent alloc] initWithName:@"launch"]];
}

- (void)handleAttributionDetectedForCampaign:(NSString *)campaignId withKeyword:(NSString *)keyword {
    [_client activateWithCampaignId:campaignId keyword:keyword];
}

- (void)recordRevenue:(double)value withCurrency:(NSString *)currency {
    [_client dispatchEvent:[[BBPEvent alloc] initMonetaryEventWithName:@"revenue" value:value currency:currency]];
}


@end

NSString *BBPCurrencyGBP = @"GBP";
NSString *BBPCurrencyUSD = @"USD";
NSString *BBPCurrencyAUD = @"AUD";
NSString *BBPCurrencyNZD = @"NZD";
