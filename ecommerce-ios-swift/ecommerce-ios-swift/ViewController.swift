//
//  ViewController.swift
//  ecommerce-ios-swift
//
//  Created by Mark Prichard on 11/16/15.
//  Copyright © 2015 AppDynamics. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var jsessionid: String = String()
    var routeid: String = String()
    var noOfItems: Int64 = 0
    let loginThruCheckout: String = "Login to Checkout"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getHttpCookies(response: NSURLResponse,
                            url : NSURL) {
        let infoPoint = ADEumInstrumentation.beginCall(self, selector: __FUNCTION__);
        let httpResponse = response as! NSHTTPURLResponse
        let headers = httpResponse.allHeaderFields as? [String : String]
        let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headers!, forURL: httpResponse.URL!)
        
        for cookie in cookies {
            if cookie.name == "JSESSIONID" {
                jsessionid = cookie.value
            }
            if cookie.name == "ROUTEID" {
                routeid = cookie.value
            }
        }
        ADEumInstrumentation.endCall(infoPoint)
    }
    
    func getHttpRequestHeaders(request: NSMutableURLRequest) {
        let infoPoint = ADEumInstrumentation.beginCall(self, selector: __FUNCTION__);
        let httpRequest = request
        let headers = httpRequest.allHTTPHeaderFields! as [String : String]
        NSLog("HTTP Request Headers: " + headers.description)
        ADEumInstrumentation.endCall(infoPoint)
    }

    func doHttpPost(url: NSURL) {
        let infoPoint = ADEumInstrumentation.beginCall(self, selector: __FUNCTION__);
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()

        let username = NSUserDefaults.standardUserDefaults().stringForKey("username")
        let password = NSUserDefaults.standardUserDefaults().stringForKey("password")
        let postString = "username=" + username! + "&password=" + password!
        let postBody = (postString as NSString).dataUsingEncoding(NSUTF8StringEncoding)

        request.HTTPBody = postBody
        request.HTTPMethod = "POST"
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

        NSLog(request.description)
        getHttpRequestHeaders(request)
        NSLog("HTTP Request Body: " + postString)
        
        session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                self.getHttpCookies(httpResponse, url: url)
                NSLog(httpResponse.description)
            }
            if (error != nil) {
                print("Error: \(error)")
                return
            }
        }).resume()
        ADEumInstrumentation.endCall(infoPoint)
    }

    func doHttpGet(url: NSURL) {
        let infoPoint = ADEumInstrumentation.beginCall(self, selector: __FUNCTION__);
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "GET"
        request.setValue(jsessionid, forHTTPHeaderField: "JSESSIONID")
        request.setValue(NSUserDefaults.standardUserDefaults().stringForKey("username")!, forHTTPHeaderField: "USERNAME")
        request.setValue(routeid, forHTTPHeaderField: "ROUTEID")
        NSLog(request.description)
        getHttpRequestHeaders(request)
        
        session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            if let httpResponse = response as? NSHTTPURLResponse {
                NSLog(httpResponse.description)
                if (data != nil) {
                    //print(NSString(data: (data)!, encoding: NSUTF8StringEncoding)!)
                }
            }
            if (error != nil) {
                print("Error: \(error)")
                return
            }
        }).resume()
        ADEumInstrumentation.endCall(infoPoint)
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        let baseUrl = NSUserDefaults.standardUserDefaults().stringForKey("url")
        let relativeUrl = "/rest/user/login"
        let url = baseUrl! + relativeUrl
        
        ADEumInstrumentation.leaveBreadcrumb("Login")
        ADEumInstrumentation.setUserData("Username", value: NSUserDefaults.standardUserDefaults().stringForKey("username")!, persist: false)
        ADEumInstrumentation.setUserData("Password", value: NSUserDefaults.standardUserDefaults().stringForKey("password")!, persist: false)
        ADEumInstrumentation.startTimerWithName(loginThruCheckout)

        self.doHttpPost(NSURL(string: url)!)
    }

    @IBAction func getItemsClicked(sender: AnyObject) {
        let baseUrl = NSUserDefaults.standardUserDefaults().stringForKey("url")
        let relativeUrl = "/rest/items/all"
        let url = baseUrl! + relativeUrl
        
        ADEumInstrumentation.leaveBreadcrumb("getItems")
        
        self.doHttpGet(NSURL(string: url)!)
    }
    
    @IBAction func addToCartClicked(sender: AnyObject) {
        let baseUrl = NSUserDefaults.standardUserDefaults().stringForKey("url")
        let relativeUrl = "/rest/cart/" + String(arc4random_uniform(10))
        let url = baseUrl! + relativeUrl
        
        ADEumInstrumentation.leaveBreadcrumb("addToCart")
        noOfItems++

        self.doHttpGet(NSURL(string: url)!)
    }
    
    @IBAction func checkoutClicked(sender: AnyObject) {
        let baseUrl = NSUserDefaults.standardUserDefaults().stringForKey("url")
        let relativeUrl = "/rest/cart/co"
        let url = baseUrl! + relativeUrl
        
        ADEumInstrumentation.leaveBreadcrumb("Checkout")
        ADEumInstrumentation.reportMetricWithName("Number of Items", value: noOfItems)

        self.doHttpGet(NSURL(string: url)!)
        ADEumInstrumentation.stopTimerWithName(loginThruCheckout)
    }
    
    @IBAction func settingsClicked(sender: AnyObject) {
        print("ECommerce URL: " + NSUserDefaults.standardUserDefaults().stringForKey("url")!)
        print("Collector URL: " + NSUserDefaults.standardUserDefaults().stringForKey("collectorUrl")!)
        print("App Key: " + NSUserDefaults.standardUserDefaults().stringForKey("appKey")!)
        print("Username: " + NSUserDefaults.standardUserDefaults().stringForKey("username")!)
        print("Password: " + NSUserDefaults.standardUserDefaults().stringForKey("password")!)
    }
}
