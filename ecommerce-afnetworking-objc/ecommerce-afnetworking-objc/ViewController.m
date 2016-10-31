//
//  ViewController.m
//  ecommerce-afnetworking-objc
//
//  Created by Mark Prichard on 12/13/15.
//  Copyright © 2015 AppDynamics E2E. All rights reserved.
//

#import "ViewController.h"

#import "AFNetworking.h"

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
    NSDictionary *headers = [(NSHTTPURLResponse*)response allHeaderFields];
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:url];
    for (int i = 0; i < [cookies count]; i++) {
        NSHTTPCookie *cookie = ((NSHTTPCookie *) [cookies objectAtIndex:i]);
        
        if ([[cookie name] isEqualToString:@"JSESSIONID"]) {
            sessionId = [[cookie properties] objectForKey:NSHTTPCookieValue];
            NSLog(@"Session ID: %@", sessionId);
        }
        if ([[cookie name] isEqualToString:@"ROUTEID"]) {
            routeId = [[cookie properties] objectForKey:NSHTTPCookieValue];
            NSLog(@"RouteID: %@", routeId);
        }
    }
}

- (void)getHttpRequestHeaders:(NSURLRequest*)request {
    NSDictionary *headers = [(NSMutableURLRequest*)request allHTTPHeaderFields];
    NSLog(@"Request Headers: %@", [headers description]);
}

- (void)getHttpResponseHeaders:(NSURLResponse*)response {
    NSDictionary *headers = [(NSHTTPURLResponse*)response allHeaderFields];
    NSLog(@"Response Headers: %@", [headers description]);
}


- (void)doHttpGet:(NSURL*)url {
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString: [url absoluteString]
                                                                                parameters:nil error:nil];
    [request setValue:sessionId forHTTPHeaderField:@"JSESSIONID"];
    [request setValue:routeId forHTTPHeaderField:@"ROUTEID"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forHTTPHeaderField:@"USERNAME"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"Request: %@", request);
    [self getHttpRequestHeaders:request];
    
    AFURLSessionManager* manager = [[AFURLSessionManager alloc] initWithSessionConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Response: %@", response);
        } else {
            NSLog(@"Error: %@", response);
        }
    }] resume];
    
}

- (IBAction)loginClicked:(id)sender {
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
    NSString *relativeURL = @"/rest/user/login";
    
    NSString *postString = @"username=";
    postString = [postString stringByAppendingString: [[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    postString = [postString stringByAppendingString:@"&password="];
    postString = [postString stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
    
    NSData *postBody = [postString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"POST body: %@", [[NSString alloc] initWithData:postBody encoding:NSUTF8StringEncoding]);

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST"
                                                                             URLString: [baseURL stringByAppendingString:relativeURL]
                                                                            parameters:nil error:nil];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postBody];
    NSLog(@"Request: %@", request);
    [self getHttpRequestHeaders:request];
    
    AFURLSessionManager* manager = [[AFURLSessionManager alloc] initWithSessionConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
     
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Response: %@", response);
            [self getHttpCookies:response forURL:[NSURL URLWithString:[baseURL stringByAppendingString:relativeURL]]];
        } else {
            NSLog(@"Error: %@", error);
        }
    }] resume];

}

- (IBAction)getItemsClicked:(id)sender {
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
    NSString *relativeURL = @"/rest/items/all";

    NSURL *url = [NSURL URLWithString:[baseURL stringByAppendingString:relativeURL]];
    [self doHttpGet:url];
}

- (IBAction)addToCartClicked:(id)sender {
    int x = arc4random() % 10;
    noOfItems++;
    
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
    NSString *relativeURL = [NSString stringWithFormat:@"/rest/cart/%d", x];
    
    NSURL *url = [NSURL URLWithString: [baseURL stringByAppendingString:relativeURL]];
    [self doHttpGet:url];
    
}

- (IBAction)checkoutClicked:(id)sender {
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
    NSString *relativeURL = @"/rest/cart/co";
    
    NSURL *url = [NSURL URLWithString: [baseURL stringByAppendingString:relativeURL]];
    [self doHttpGet:url];
}

- (IBAction)settingsClicked:(id)sender {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"ECommerce URL: %@", [standardDefaults objectForKey:@"url"]);
    NSLog(@"EUM Collector: %@", [standardDefaults objectForKey:@"collectorUrl"]);
    NSLog(@"EUM Key: %@", [standardDefaults objectForKey:@"appKey"]);
    NSLog(@"Username: %@", [standardDefaults objectForKey:@"username"]);
    NSLog(@"Password: %@", [standardDefaults objectForKey:@"password"]);
}

@end
