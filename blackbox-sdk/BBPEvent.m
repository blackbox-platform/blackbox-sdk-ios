//  BBPEvent.m
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import "BBPEvent.h"

@implementation BBPEvent {
    NSDictionary *_data;
}

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _type = BBPStandardEvent;
        _data = @{@"name": name};
    }
    
    return self;
}

- (instancetype)initMonetaryEventWithName:(NSString *)name value:(double)value currency:(NSString *)currency {
    if (self = [super init]) {
        _type = BBPRevenueEvent;
        _data = @{@"name": name, @"value": [NSNumber numberWithDouble:value], @"currency": currency};
    }
    
    return self;
}

- (NSData *)payloadWithAttributionKeyword:(NSString *)keyword error:(NSError *__autoreleasing *)error {
    NSMutableDictionary *payload = [_data mutableCopy];
    payload[@"keyword"] = keyword;

    return [NSJSONSerialization dataWithJSONObject:payload options:0 error:error];
}

@end
