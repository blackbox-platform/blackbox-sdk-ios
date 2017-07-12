//  BBPClient.h
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <Foundation/Foundation.h>

@class BBPEvent;

@interface BBPClient : NSObject

- (instancetype)initWithToken:(NSString *)token uuid:(NSString *)uuid;

- (void)activateWithCampaignId:(NSString *)campaignId keyword:(NSObject *)keyword;
- (void)disable;

- (void)dispatchEvent:(BBPEvent *)event;

@end
