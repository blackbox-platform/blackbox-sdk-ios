//  BBPEvent.m
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import "BBPEvent.h"

@implementation BBPEvent {
    NSDictionary *_data;
    NSInteger _id;
}

- (instancetype)initWithType:(BBPEventType)type payload:(NSDictionary *)payload {
    if (self = [super init]) {
        _type = type;
        _data = payload;
        arc4random_buf(&_id, sizeof(_id));
    }
    
    return self;
}

- (instancetype)initWithName:(NSString *)name {
    return [self initWithType:BBPStandardEvent payload:@{@"name": name}];
}

- (instancetype)initMonetaryEventWithName:(NSString *)name value:(double)value currency:(NSString *)currency {
    return [self initWithType:BBPRevenueEvent payload:@{@"name": name, @"value": [NSNumber numberWithDouble:value], @"currency": currency}];
}

- (NSData *)payloadWithAttributionKeyword:(NSObject *)keyword uuid:(NSString *)uuid error:(NSError *__autoreleasing *)error {
    NSMutableDictionary *payload = [_data mutableCopy];
    payload[@"keyword"] = keyword;
    payload[@"id"] = @(_id);
    payload[@"user"] = uuid;

    return [NSJSONSerialization dataWithJSONObject:payload options:0 error:error];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@", [self typeDescription], @(_id), _data];
}

- (NSString *)typeDescription {
    switch (_type) {
        case BBPRevenueEvent: return @"RevenueEvent";
        case BBPStandardEvent: return @"StandardEvent";
    }
}

@end
