//  BBPEventManager.m
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import "BBPEventManager.h"
#import "BBPEvent.h"
#import "Util.h"

#ifdef BLACKBOX_DEBUG
#define BLACKBOX_API [NSProcessInfo processInfo].environment[@"BLACKBOX_API"]
#else
#define BLACKBOX_API @"https://blackbox-platform-prod.herokuapp.com"
#endif


typedef enum {
    STATE_PENDING,
    STATE_DISABLED,
    STATE_ACTIVE,
} BBPEventManagerState;


@implementation BBPEventManager {
    NSObject<BBPEventManagerDelegate> *_delegate;
    NSString *_campaignId;
    NSObject *_keyword;
    NSMutableArray *_eventQueue;
    BBPEventManagerState _state;
}

- (instancetype)initWithDelegate:(NSObject<BBPEventManagerDelegate> *)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _eventQueue = [NSMutableArray new];
        _state = STATE_PENDING;
    }
    
    return self;
}

- (void)handleApplicationLaunched {
    if ([_delegate isFirstApplicationLaunch]) {
        [self dispatchEvent:[[BBPEvent alloc] initWithName:@"install"]];
    }
    
    [self dispatchEvent:[[BBPEvent alloc] initWithName:@"launch"]];
    
    if ([_delegate savedCampaignId]) {
        [self activateWithCampaignId:[_delegate savedCampaignId] keyword:[NSNull null]];

    } else {
        [_delegate requestAttributionInformationWithBlock:^(NSString *campaignId, NSObject *keyword) {
            [self activateWithCampaignId:campaignId keyword:keyword];
        }];
    }
}

- (void)recordRevenue:(double)value withCurrency:(NSString *)currency {
    [self dispatchEvent:[[BBPEvent alloc] initMonetaryEventWithName:@"revenue" value:value currency:currency]];
}

- (void)activateWithCampaignId:(NSString *)campaignId keyword:(NSObject *)keyword {
    LogDebug(@"Activating");

    _campaignId = campaignId;
    _keyword = keyword;
    _state = STATE_ACTIVE;
    
    for (BBPEvent *evt in _eventQueue) {
        [self dispatchEvent:evt];
    }
    
    [_eventQueue removeAllObjects];
}

- (void)disable {
    LogDebug(@"Disabling");
    _state = STATE_DISABLED;
    [_eventQueue removeAllObjects];
}

- (void)dispatchEvent:(BBPEvent *)event {
    LogDebug(@"Dispatch event");
    LogDebug(event);

    switch (_state) {
        case STATE_ACTIVE: {
            NSURL *url = [self urlForEventType:event.type];
            [_delegate dispatchEventWithPayload:[event payloadWithUserId:[_delegate userId]] url:url];

            return;
        }
        case STATE_PENDING: {
            LogDebug(@"Enqueued event");
            [_eventQueue addObject:event];

            return;
        }
        case STATE_DISABLED: {
            LogDebug(@"Discarded event");

            return;
        }
    }
}

- (NSURL *)urlForEventType:(BBPEventType)type {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/campaigns/%@/%@", BLACKBOX_API, _campaignId, [self urlSlugForEventType:type]]];
}

- (NSString *)urlSlugForEventType:(BBPEventType)type {
    switch (type) {
        case BBPRevenueEvent: return @"revenueAttributionEvents";
        case BBPStandardEvent: return @"attributionEvents";
    }
}

@end
