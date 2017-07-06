//  Util.h
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <Foundation/Foundation.h>

static void LogError(id error) {
    NSLog(@"[Blackbox] %@", error);
}

static void LogDebug(id msg) {
#ifdef BLACKBOX_DEBUG
    NSLog(@"[Blackbox] %@", msg);
#endif
}
