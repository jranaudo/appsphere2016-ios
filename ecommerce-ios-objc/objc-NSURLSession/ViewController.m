//
//  ViewController.m
//  objc-NSURLSession
//
//  Created by Mark Prichard on 11/16/15.
//  Copyright © 2015 AppDynamics. All rights reserved.
//

#import "ViewController.h"
#import <ADEUMInstrumentation/ADEUMInstrumentation.h>

@interface ViewController ()

@end

@implementation ViewController

NSString *sessionId = nil;
NSString *routeId = nil;
NSString *loginThruCheckout = @"Login to Checkout";
int noOfItems = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getHttpCookies:(NSURLResponse*)response
                forURL:(NSURL*)url {
    id infoPoint = [ADEumInstrumentation beginCall:self selector:_cmd];
    NSDictionary *headers = [(NSHTTPURLResponse*)response allHeaderFields];
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:url];
    for (int i = 0; i < [cookies count]; i++) {
        NSHTTPCookie *cookie = ((NSHTTPCookie *) [cookies objectAtIndex:i]);
        
        if ([[cookie name] isEqualToString:@"JSESSIONID"]) {
            sessionId = [[cookie properties] objectForKey:NSHTTPCookieValue];
        }
        if ([[cookie name] isEqualToString:@"ROUTEID"]) {
            routeId = [[cookie properties] objectForKey:NSHTTPCookieValue];
        }
    }
    [ADEumInstrumentation endCall:infoPoint];
}

- (void)getHttpRequestHeaders:(NSURLRequest*)request {
    id infoPoint = [ADEumInstrumentation beginCall:self selector:_cmd];
    NSDictionary *headers = [(NSMutableURLRequest*)request allHTTPHeaderFields];
    NSLog(@"Request Headers: %@", [headers description]);
    [ADEumInstrumentation endCall:infoPoint];
}

- (void)getHttpResponseHeaders:(NSURLResponse*)response {
    id infoPoint = [ADEumInstrumentation beginCall:self selector:_cmd];
    NSDictionary *headers = [(NSHTTPURLResponse*)response allHeaderFields];
    NSLog(@"Response Headers: %@", [headers description]);
    [ADEumInstrumentation endCall:infoPoint];
}

- (void)doHttpGet:(NSURL*)url {
    id infoPoint = [ADEumInstrumentation beginCall:self selector:_cmd];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:sessionId forHTTPHeaderField:@"JSESSIONID"];
    [request setValue:routeId forHTTPHeaderField:@"ROUTEID"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"username" ]forHTTPHeaderField:@"USERNAME"];
    [self getHttpRequestHeaders:request];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    NSLog(@"Request URL: %@", url);
                    NSLog(@"HTTP Status Code: %ld", [(NSHTTPURLResponse*)response statusCode]);
                    [self getHttpResponseHeaders:response];
                }] resume];
    [ADEumInstrumentation endCall:infoPoint];
}

- (void)doHttpPost:(NSURL*)url {
    id infoPoint = [ADEumInstrumentation beginCall:self selector:_cmd];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:60.0];
    
    NSString *postString = @"username=";
    postString = [postString stringByAppendingString: [[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    postString = [postString stringByAppendingString:@"&password="];
    postString = [postString stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
    NSData *postBody = [postString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"POST body: %@", [[NSString alloc] initWithData:postBody encoding:NSUTF8StringEncoding]);
    
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postBody];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error) {
        NSLog(@"Request URL: %@", url);
        NSLog(@"HTTP Status Code %ld", [(NSHTTPURLResponse*)response statusCode]);
        
        [self getHttpCookies:response forURL:url];
        [self getHttpResponseHeaders:response];
    }] resume];
    [ADEumInstrumentation endCall:infoPoint];
}

- (IBAction)loginClicked:(id)sender {
    [ADEumInstrumentation leaveBreadcrumb:@"loginClicked"];
    [ADEumInstrumentation startTimerWithName:loginThruCheckout];
    
    [ADEumInstrumentation setUserData: @"Username" value:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] persist:false];
    [ADEumInstrumentation setUserData: @"Password" value:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] persist:false];
    
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
    NSString *relativeURL = @"/rest/user/login";
    NSURL *url = [NSURL URLWithString:[baseURL stringByAppendingString:relativeURL]];
    [self doHttpPost:url];
}

- (IBAction)getItemsClicked:(id)sender {
    [ADEumInstrumentation leaveBreadcrumb:@"getItemsClicked"];
    
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
    NSString *relativeURL = @"/rest/items/all";
    NSURL *url = [NSURL URLWithString:[baseURL stringByAppendingString:relativeURL]];
    [self doHttpGet:url];
}

- (IBAction)addToCartClicked:(id)sender {
    [ADEumInstrumentation leaveBreadcrumb:@"addToCartClicked"];
    
    int x = arc4random() % 10;
    noOfItems++;
    
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
    NSString *relativeURL = [NSString stringWithFormat:@"/rest/cart/%d", x];
    NSURL *url = [NSURL URLWithString: [baseURL stringByAppendingString:relativeURL]];
    [self doHttpGet:url];
}

- (IBAction)checkoutClicked:(id)sender {
    [ADEumInstrumentation leaveBreadcrumb:@"checkoutClicked"];
    [ADEumInstrumentation reportMetricWithName:@"No of Items" value: noOfItems];
    [ADEumInstrumentation stopTimerWithName:loginThruCheckout];
    
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
    NSString *relativeURL = @"/rest/cart/co";
    NSURL *url = [NSURL URLWithString: [baseURL stringByAppendingString:relativeURL]];
    [self doHttpGet:url];
}

- (IBAction)settingsClicked:(id)sender {
    [ADEumInstrumentation leaveBreadcrumb:@"settingsClicked"];
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"ECommerce URL: %@", [standardDefaults objectForKey:@"url"]);
    NSLog(@"EUM Collector: %@", [standardDefaults objectForKey:@"collectorUrl"]);
    NSLog(@"EUM Key: %@", [standardDefaults objectForKey:@"appKey"]);
    NSLog(@"Username: %@", [standardDefaults objectForKey:@"username"]);
    NSLog(@"Password: %@", [standardDefaults objectForKey:@"password"]);
}

@end
