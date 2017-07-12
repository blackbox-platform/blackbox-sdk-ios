//  BBPMockEventManagerDelegate.h
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <Foundation/Foundation.h>
#import "BBPEventManager.h"

@interface BBPMockEventManagerDelegate : NSObject <BBPEventManagerDelegate>

@property (assign) BOOL isFirstApplicationLaunch;

@property (copy) NSString *savedCampaignId;
@property (copy) NSString *fetchedCampaignId;
@property (copy) NSString *fetchedKeyword;

- (NSDictionary *)eventAtPath:(NSString *)path ofType:(NSString *)type;
- (NSArray *)eventsAtPath:(NSString *)path ofType:(NSString *)type;
- (NSArray *)events;

@end
