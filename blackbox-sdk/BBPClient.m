//  BBPClient.m
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import "BBPClient.h"
#import "BBPEvent.h"
#import "Util.h"

#ifdef DEBUG
#define BLACKBOX_API [NSProcessInfo processInfo].environment[@"BLACKBOX_API"]
#else
#define BLACKBOX_API @"https://blackbox-platform-prod.herokuapp.com"
#endif


typedef enum {
    STATE_PENDING,
    STATE_DISABLED,
    STATE_ACTIVE,
} BBPClientState;


@implementation BBPClient {
    NSString *_campaignId;
    NSString *_token;
    NSString *_keyword;
    NSMutableArray *_eventQueue;
    BBPClientState _state;
}

- (instancetype)initWithToken:(NSString *)token {
    if (self = [super init]) {
        _token = token;
        _eventQueue = [NSMutableArray new];
        _state = STATE_PENDING;
    }
    
    return self;
}

- (void)activateWithCampaignId:(NSString *)campaignId keyword:(NSString *)keyword {
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
            NSError *error;
            NSData *body = [event payloadWithAttributionKeyword:_keyword error:&error];
            if (error) {
                LogError(error);
                return;
            }
            
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[self urlForEventType:event.type]];
            
            [req setHTTPMethod:@"POST"];
            [req setHTTPBody:body];
            [req setValue:[NSString stringWithFormat:@"Bearer %@", _token] forHTTPHeaderField:@"Authorization"];
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    LogError(error);
                } else {
                    LogDebug(@"Event dispatched successfuly");
                }
            }] resume];

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
