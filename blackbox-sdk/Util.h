//  Util.h
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <Foundation/Foundation.h>

static inline void LogError(id error) {
    NSLog(@"[Blackbox] %@", error);
}

static inline void LogDebug(id msg) {
#ifdef BLACKBOX_DEBUG
    NSLog(@"[Blackbox] %@", msg);
#endif
}

static inline NSDictionary *InfoPlist() {
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
}
