//
//  Battery.swift
//  WatchDog
//
//  Created by Ryan Lucas on 3/16/17.
//  Copyright © 2017 Ryan Lucas. All rights reserved.
//

import UIKit
import OAuthSwift


class Battery: UIViewController {
    
    
    let myNotification = Notification.Name(rawValue:"MyNotification")
    
    
    let oauthswift = OAuth2Swift(
        consumerKey:    "fdcb4ac3295906a977f6317979ffaab6d11d93e833c1f41ed834c2b0908cdf2c",
        consumerSecret: "4ca58af6e0b5c9188d17fc92366c86b8f1f4c8bd9e77ef847edc6479487ef120",
        authorizeUrl:   "https://app.fitbark.com/oauth/authorize",
        accessTokenUrl: "https://app.fitbark.com/oauth/token",
        responseType:   "code"
    )

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
  

    func batterystatus(dogslug: String) -> Int {
        let nc = NotificationCenter.default
        var batterylife:Int = 0
        self.oauthswift.client.credential.oauthToken = WatchViewController.DogAuth.token
        let dogURL = "https://app.fitbark.com/api/v2/dog/\(dogslug)"
        let _ = self.oauthswift.client.get(dogURL, parameters: [:], success: { response in
        let jsonDict = try? response.jsonObject() as AnyObject!
        let ourdogfromfitbark = jsonDict?["dog"] as! NSDictionary?
        batterylife = (ourdogfromfitbark!["battery_level"] as! Int?)!
            print("Battery life: \(batterylife)")
            nc.post(name:self.myNotification,
                    object: nil,
                    userInfo:["batterylevel":batterylife])
        },
                              failure: { error in
                                print(error.description)
        })
        
        
        //userInfo:["message":"Hello there!", "date":Date()])
        return batterylife //return 1 if succesful
    }
    
}
