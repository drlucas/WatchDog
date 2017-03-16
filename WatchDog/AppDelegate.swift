//
//  AppDelegate.swift
//  WatchDog
//
//  Created by Ryan Lucas on 12/31/16.
//  Copyright © 2016 Ryan Lucas. All rights reserved.
//

import UIKit
import OAuthSwift
import WatchConnectivity


@UIApplicationMain



class AppDelegate: UIResponder, UIApplicationDelegate {//, WCSessionDelegate  {
    
           var window: UIWindow?
   
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
           // print("starting up")
          
            return true
        }
        
        func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
            print ("Handle URL")
            applicationHandle(url: url)
            return true
        }
        
        @available(iOS 9.0, *)
        func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
            print ("Handle URL ios 9+")
            applicationHandle(url: url)
            return true
        }
    
    func applicationHandle(url: URL) {
        print ("URL: \(url)")
        if (url.host == "oauth-callback") {
            OAuthSwift.handle(url: url)
            print("Url.host = \(url.host)")
        }
    }

}

class Authentication {
    var authtoken = "" as String! // my authentication token to use in fitbark
    
}
