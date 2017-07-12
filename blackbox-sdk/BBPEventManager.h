//  BBPEventManager.h
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <Foundation/Foundation.h>

@class BBPEvent;

@protocol BBPEventManagerDelegate <NSObject>

- (NSString *)userId;

- (BOOL)isFirstApplicationLaunch;
- (NSString *)savedCampaignId;
- (void)saveCampaignId:(NSString *)campaignId;

- (void)requestAttributionInformationWithBlock:(void(^)(NSString *campaignId, NSObject *keyword))block;
- (void)dispatchEventWithPayload:(NSDictionary *)data url:(NSURL *)url;

@end


@interface BBPEventManager : NSObject

- (instancetype)initWithDelegate:(NSObject<BBPEventManagerDelegate> *)delegate;

- (void)handleApplicationLaunched;
- (void)recordRevenue:(double)value withCurrency:(NSString *)currency;

@end
