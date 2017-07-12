//  BlackboxSDK.m
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <AdSupport/AdSupport.h>

#import "BlackboxSDK.h"
#import "BBPEventManager.h"
#import "BBPEvent.h"
#import "Util.h"

@interface BlackboxSDK () <BBPEventManagerDelegate>
@end

@implementation BlackboxSDK {
    BBPEventManager *_eventManager;
}

#define BLACKBOX_TOKEN_ID @"BBPEventManagerID"

static NSString *HAS_LAUNCHED_KEY = @"BBPApplicationHasLaunched___";
static NSString *UUID_KEY = @"BBPUserIdentifier";
static NSString *CAMPAIGN_ID_KEY = @"BBPCampaignID";

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:[self sdk]
                                             selector:@selector(handleApplicationLaunched:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
}

+ (instancetype)sdk {
    static BlackboxSDK *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [self new];
    });

    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _eventManager = [[BBPEventManager alloc] initWithDelegate:self];
    }
    
    return self;
}

- (void)handleApplicationLaunched:(id)_ {
    [_eventManager handleApplicationLaunched];
}

- (void)recordRevenue:(double)value withCurrency:(NSString *)currency {
    [_eventManager recordRevenue:value withCurrency:currency];
}


# pragma mark - as BBPEventManagerDelegate:

- (NSString *)token {
    static NSString *token;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *info = InfoPlist();
        
        if (info[BLACKBOX_TOKEN_ID]) {
            token = info[BLACKBOX_TOKEN_ID];
            
        } else {
            LogError(@"BBPClientID is not set in your Info.plist. Blackbox Platform will not receive attribution events until this is added.");
        }
    });
    
    return token;
}

- (NSString *)userId {
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

- (BOOL)isFirstApplicationLaunch {
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

- (NSString *)savedCampaignId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:CAMPAIGN_ID_KEY];
}

- (void)saveCampaignId:(NSString *)id {
    [[NSUserDefaults standardUserDefaults] setObject:id forKey:CAMPAIGN_ID_KEY];
}

- (void)requestAttributionInformationWithBlock:(void (^)(NSString *campaignId, NSObject *keyword))block {
    [self requestAttributionDictionaryWithBlock:^(NSDictionary *details, NSError *error) {
        if (!details || !details[@"iad-attribution"]) {
            block(nil, nil);
        }
        
        
        NSString *campaignId = details[@"iad-campaign-id"];
        NSString *keyword = details[@"iad-keyword"] ?: [NSNull null];

        block(campaignId, keyword);
    }];
}

- (void)dispatchEventWithPayload:(NSDictionary *)payload url:(NSURL *)url {
    NSError *error;
    NSData *body = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];

    if (error) {
        LogError(error);
        return;
    }
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    [req setHTTPMethod:@"PUT"];
    [req setHTTPBody:body];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"Bearer %@", [self token]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            LogError(error);
        } else {
            LogDebug(@"Event dispatched");
            LogError(response);
        }
    }];
    
    [task resume];
}


#pragma mark - Private:

- (NSString *)initialUUID {
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        
    } else {
        return [[NSUUID UUID] UUIDString];
    }
}

- (void)requestAttributionDictionaryWithBlock:(void (^)(NSDictionary *details, NSError *error))block {
#ifdef BLACKBOX_DEBUG
    block([NSProcessInfo processInfo].environment, nil);
    
#else
    [[ADClient sharedClient] requestAttributionDetailsWithBlock:block];

#endif
}

@end

NSString *BBPCurrencyGBP = @"GBP";
NSString *BBPCurrencyUSD = @"USD";
NSString *BBPCurrencyAUD = @"AUD";
NSString *BBPCurrencyNZD = @"NZD";
