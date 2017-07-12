//  BBPEvent.h
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <Foundation/Foundation.h>

typedef enum {
    BBPRevenueEvent,
    BBPStandardEvent
} BBPEventType;

@interface BBPEvent : NSObject

- (instancetype)initMonetaryEventWithName:(NSString *)name value:(double)value currency:(NSString *)currency;
- (instancetype)initWithName:(NSString *)name keyword:(NSString *)keyword;
- (instancetype)initWithName:(NSString *)name;

@property (assign, readonly) BBPEventType type;

- (NSDictionary *)payloadWithUserId:(NSString *)uuid;

@end
