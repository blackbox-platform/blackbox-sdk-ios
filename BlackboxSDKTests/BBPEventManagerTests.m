//  BlackboxSDKTests.m
//  Copyright © 2017 Redbox Mobile. All rights reserved.

#import <XCTest/XCTest.h>
#import "BBPEventManager.h"
#import "BBPMockEventManagerDelegate.h"

@interface BBPEventManagerTests : XCTestCase
@end

@implementation BBPEventManagerTests

- (void)testShouldNotSendEventsBeforeAttributionIsDetermined {
    BBPMockEventManagerDelegate *delegate = [BBPMockEventManagerDelegate new];
    BBPEventManager *manager = [[BBPEventManager alloc] initWithDelegate:delegate];
    
    [manager handleApplicationLaunched];
    
    XCTAssertEqualObjects([delegate events], @[]);
}

- (void)testShouldSendLaunchEventsWhenSearchAdsReturnsAttributionDetails {
    BBPMockEventManagerDelegate *delegate = [BBPMockEventManagerDelegate new];
    delegate.fetchedKeyword = @"turtles";
    delegate.fetchedCampaignId = @"123";
    BBPEventManager *manager = [[BBPEventManager alloc] initWithDelegate:delegate];
    
    [manager handleApplicationLaunched];
    
    NSDictionary *event = [delegate eventAtPath:@"/campaigns/123/attributionEvents"
                                         ofType:@"launch"];
    
    XCTAssertNotNil(event);
}

- (void)testShouldSendLaunchEventsWhenSavedAttributionDetails {
    BBPMockEventManagerDelegate *delegate = [BBPMockEventManagerDelegate new];
    delegate.savedCampaignId = @"123";
    BBPEventManager *manager = [[BBPEventManager alloc] initWithDelegate:delegate];
    
    [manager handleApplicationLaunched];
    
    NSDictionary *event = [delegate eventAtPath:@"/campaigns/123/attributionEvents"
                                         ofType:@"launch"];
    
    XCTAssertNotNil(event);
    XCTAssertNotNil(event[@"id"]);
    XCTAssertEqualObjects(event[@"user"], delegate.userId);
}

- (void)testShouldSendInstallEventWhenAppIsNewlyInstalled {
    BBPMockEventManagerDelegate *delegate = [BBPMockEventManagerDelegate new];
    delegate.savedCampaignId = @"123";
    delegate.isFirstApplicationLaunch = YES;
    BBPEventManager *manager = [[BBPEventManager alloc] initWithDelegate:delegate];
    
    [manager handleApplicationLaunched];
    
    NSDictionary *event = [delegate eventAtPath:@"/campaigns/123/attributionEvents"
                                         ofType:@"install"];
    
    XCTAssertNotNil(event);
    XCTAssertNotNil(event[@"id"]);
    XCTAssertEqualObjects(event[@"user"], delegate.userId);
}

- (void)testShouldNotSendInstallEventWhenAppIsNotNewlyInstalled {
    BBPMockEventManagerDelegate *delegate = [BBPMockEventManagerDelegate new];
    delegate.savedCampaignId = @"123";
    delegate.isFirstApplicationLaunch = NO;
    BBPEventManager *manager = [[BBPEventManager alloc] initWithDelegate:delegate];
    
    [manager handleApplicationLaunched];
    
    NSDictionary *event = [delegate eventAtPath:@"/campaigns/123/attributionEvents"
                                         ofType:@"install"];
    
    XCTAssertNil(event);
}

- (void)testShouldSendRevenueEventOnRequestByUser {
    BBPMockEventManagerDelegate *delegate = [BBPMockEventManagerDelegate new];
    delegate.savedCampaignId = @"123";
    BBPEventManager *manager = [[BBPEventManager alloc] initWithDelegate:delegate];
    
    [manager handleApplicationLaunched];
    [manager recordRevenue:12.3 withCurrency:@"GBP"];
    
    NSDictionary *event = [delegate eventAtPath:@"/campaigns/123/revenueAttributionEvents"
                                         ofType:@"revenue"];
    
    XCTAssertNotNil(event);
    XCTAssertEqualObjects(event[@"value"], @12.3);
    XCTAssertEqualObjects(event[@"currency"], @"GBP");
    XCTAssertNotNil(event[@"id"]);
    XCTAssertEqualObjects(event[@"user"], delegate.userId);
}

@end
