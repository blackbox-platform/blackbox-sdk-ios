//  BlackboxSDK.m
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <AdSupport/AdSupport.h>

#import "BlackboxSDK.h"
#import "BBPClient.h"
#import "BBPEvent.h"
#import "Util.h"

@implementation BlackboxSDK {
    BBPClient *_client;
}

#define BLACKBOX_TOKEN_ID @"BBPClientID"

static NSString *HAS_LAUNCHED_KEY = @"BBPApplicationHasLaunched___";
static NSString *UUID_KEY = @"BBPUserIdentifier";
static NSString *CAMPAIGN_ID_KEY = @"BBPCampaignID";

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:[self sdk]
                                             selector:@selector(handleApplicationLaunched:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    if ([self attributedCampaignId]) {
        [[self sdk] handleAttributionDetectedForCampaign:[self attributedCampaignId] withKeyword:[NSNull null]];

    } else {
        [self requestAttributionDetailsWithBlock:^(NSDictionary *attributionDetails, NSError *error) {
            if (attributionDetails[@"iad-attribution"] && attributionDetails[@"iad-campaign-id"]) {
                [[self sdk] handleAttributionDetectedForCampaign:attributionDetails[@"iad-campaign-id"]
                                                     withKeyword:attributionDetails[@"iad-keyword"]];
            }
        }];
    }
}

+ (void)requestAttributionDetailsWithBlock:(void (^)(NSDictionary *attributionDetails, NSError *error))completionHandler {
#ifdef BLACKBOX_DEBUG
    completionHandler([NSProcessInfo processInfo].environment, nil);
#else
    [[ADClient sharedClient] requestAttributionDetailsWithBlock:completionHandler];
#endif
}

+ (instancetype)sdk {
    static BlackboxSDK *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];

        if (info[BLACKBOX_TOKEN_ID]) {
            instance = [[self alloc] initWithToken:info[BLACKBOX_TOKEN_ID]];
            LogDebug(@"Initialized client");

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
        _client = [[BBPClient alloc] initWithToken:token uuid:[BlackboxSDK uuid]];
    }
    
    return self;
}

- (void)handleApplicationLaunched:(id)_ {
    if ([BlackboxSDK isFirstLaunchAfterInstall]) {
        [_client dispatchEvent:[[BBPEvent alloc] initWithName:@"install"]];
    }
    
    [_client dispatchEvent:[[BBPEvent alloc] initWithName:@"launch"]];
}

- (void)handleAttributionDetectedForCampaign:(NSString *)campaignId withKeyword:(NSObject *)keyword {
    [_client activateWithCampaignId:campaignId keyword:keyword];
    [BlackboxSDK setAttributedCampaignId:campaignId];
}

- (void)recordRevenue:(double)value withCurrency:(NSString *)currency {
    [_client dispatchEvent:[[BBPEvent alloc] initMonetaryEventWithName:@"revenue" value:value currency:currency]];
}

+ (BOOL)isFirstLaunchAfterInstall {
    static BOOL value = NO;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        if (![[NSUserDefaults standardUserDefaults] boolForKey:HAS_LAUNCHED_KEY]) {
            value = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HAS_LAUNCHED_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
    
    return value;
}

+ (NSString *)uuid {
    static NSString *value;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[NSUserDefaults standardUserDefaults] boolForKey:UUID_KEY]) {
            [[NSUserDefaults standardUserDefaults] setObject:[self initialUUID] forKey:UUID_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        value = [[NSUserDefaults standardUserDefaults] objectForKey:UUID_KEY];
    });
    
    return value;
}

+ (NSString *)attributedCampaignId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:CAMPAIGN_ID_KEY];
}

+ (void)setAttributedCampaignId:(NSString *)id {
    [[NSUserDefaults standardUserDefaults] setObject:id forKey:CAMPAIGN_ID_KEY];
}

+ (NSString *)initialUUID {
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];

    } else {
        return [[NSUUID UUID] UUIDString];
    }
}

NSString *BBPCurrencyGBP = @"GBP";
NSString *BBPCurrencyUSD = @"USD";
NSString *BBPCurrencyAUD = @"AUD";
NSString *BBPCurrencyNZD = @"NZD";

@end

