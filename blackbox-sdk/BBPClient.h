//  BBPClient.h
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <Foundation/Foundation.h>

@class BBPEvent;

@interface BBPClient : NSObject

- (instancetype)initWithToken:(NSString *)token;

- (void)activateWithCampaignId:(NSString *)campaignId keyword:(NSString *)keyword;
- (void)disable;

- (void)dispatchEvent:(BBPEvent *)event;

@end
