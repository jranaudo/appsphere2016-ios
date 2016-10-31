//
//  objc_NSURLSessionUITests.m
//  objc-NSURLSessionUITests
//
//  Created by Mark Prichard on 11/16/15.
//  Copyright © 2015 AppDynamics E2E. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface objc_NSURLSessionUITests : XCTestCase

@end

@implementation objc_NSURLSessionUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    [app.buttons[@"Login"] tap];
    [NSThread sleepForTimeInterval:2.0f];
    
    [app.buttons[@"Get Items"] tap];
    [NSThread sleepForTimeInterval:5.0f];
    
    int x = arc4random() % 10;
    for (int i = 0; i < x; i++) {
        [app.buttons[@"Add to Cart"] tap];
        [NSThread sleepForTimeInterval:5.0f];
    }
    
    [app.buttons[@"Checkout"] tap];
    [NSThread sleepForTimeInterval:20.0f];
    
    [app.buttons[@"Settings"] tap];
}

@end
