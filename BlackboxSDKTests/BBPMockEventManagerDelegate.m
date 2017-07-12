//  BBPMockEventManagerDelegate.m
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import "BBPMockEventManagerDelegate.h"

@implementation BBPMockEventManagerDelegate {
    NSMutableArray *_events;
}

- (instancetype)init {
    if (self = [super init]) {
        _events = [NSMutableArray new];
    }
    
    return self;
}

- (NSString *)userId {
    return @"user";
}

- (void)saveCampaignId:(NSString *)campaignId {
    _savedCampaignId = campaignId;
}

- (void)requestAttributionInformationWithBlock:(void (^)(NSString *, NSObject *))block {
    if (_fetchedCampaignId && _fetchedKeyword) {
        block(_fetchedCampaignId, _fetchedKeyword);
    }
}

- (void)dispatchEventWithPayload:(NSDictionary *)data url:(NSURL *)url {
    [_events addObject:@{@"url": url, @"data": data}];
}

- (NSArray *)eventsAtPath:(NSString *)path ofType:(NSString *)type {
    NSMutableArray *res = [NSMutableArray new];
    
    for (NSDictionary *evt in _events) {
        NSURL *url = evt[@"url"];
        NSDictionary *data = evt[@"data"];
        
        if ([url.path isEqualToString:path] && [data[@"name"] isEqualToString:type]) {
            [res addObject:data];
        }
    }
    
    return res;
}

- (NSDictionary *)eventAtPath:(NSString *)path ofType:(NSString *)type {
    return [[self eventsAtPath:path ofType:type] firstObject];
}

- (NSArray *)events {
    NSMutableArray *res = [NSMutableArray new];
    
    for (NSDictionary *evt in _events) {
        NSDictionary *data = evt[@"data"];
        [res addObject:data];
    }
    
    return res;
}

@end
