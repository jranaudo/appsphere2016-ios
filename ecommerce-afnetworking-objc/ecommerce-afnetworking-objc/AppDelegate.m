//
//  AppDelegate.m
//  ecommerce-afnetworking-objc
//
//  Created by Mark Prichard on 12/13/15.
//  Copyright © 2015 AppDynamics E2E. All rights reserved.
//

#import "AppDelegate.h"
#import <ADEUMInstrumentation/ADEUMInstrumentation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self loadAppDefaults];
    
    NSString* appKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"appKey"];
    NSString* collectorURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"collectorUrl"];
    
    ADEumAgentConfiguration* agentConfig = [[ADEumAgentConfiguration alloc] init];
    agentConfig.appKey = appKey;
    agentConfig.collectorURL = collectorURL;
    
    // 4.3: use agentConfig.loggingLevel
    //agentConfig.loggingLevel = ADEumLoggingLevelAll;
    agentConfig.enableLogging = true;
    
    [ADEumInstrumentation initWithConfiguration:agentConfig];

    // 4.2 - for 4.3 use initWithConfiguration
    //[ADEumInstrumentation initWithKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"appKey"]
    //                     collectorUrl:[[NSUserDefaults standardUserDefaults] objectForKey:@"collectorUrl"]
    //                    enableLogging:true ];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)loadAppDefaults
{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"ECommerce" ofType: @"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: path];
    NSLog(@"%@", dict);
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"ECommerce URL"] forKey:@"url"];
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"EUM Collector"] forKey:@"collectorUrl"];
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"Username"] forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"Password"] forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"EUM App Key"] forKey:@"appKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
