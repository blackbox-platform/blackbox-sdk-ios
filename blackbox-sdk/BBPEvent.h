//  BBPEvent.h
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <Foundation/Foundation.h>

typedef enum {
    BBPRevenueEvent,
    BBPStandardEvent
} BBPEventType;

@interface BBPEvent : NSObject

- (instancetype)initMonetaryEventWithName:(NSString *)name value:(double)value currency:(NSString *)currency;
- (instancetype)initWithName:(NSString *)name;

@property (assign, readonly) BBPEventType type;

- (NSData *)payloadWithAttributionKeyword:(NSObject *)keyword uuid:(NSString *)uuid error:(NSError *__autoreleasing *)error;

@end
