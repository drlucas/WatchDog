//
//  MonthlyActivityViewController.swift
//  WatchDog
//
//  Created by Ryan Lucas on 3/23/17.
//  Copyright © 2017 Ryan Lucas. All rights reserved.
//

import UIKit
import CloudKit
import Charts
import OAuthSwift

class MonthlyActivityViewController: UIViewController {

    let publicDB = CKContainer.default().publicCloudDatabase
    let oauthswift = OAuth2Swift(
        consumerKey:    "fdcb4ac3295906a977f6317979ffaab6d11d93e833c1f41ed834c2b0908cdf2c",
        consumerSecret: "4ca58af6e0b5c9188d17fc92366c86b8f1f4c8bd9e77ef847edc6479487ef120",
        authorizeUrl:   "https://app.fitbark.com/oauth/authorize",
        accessTokenUrl: "https://app.fitbark.com/oauth/token",
        responseType:   "code"
    )
    
    var fitbptlist:[Int] = []   // the fitbark points we received for each day
    var ptsvalue = 0
    var dogslug:String! // the slug for the dog

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print ("lets show the daily average for the current month for \(dogslug)")
        graphMonthlyActivity()
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
    
    
    
    
    
    func graphMonthlyActivity() {
    //Get activity information from icloud
    //if we don't have an icloud record for this date/range then get from fitbark api and save to icloud
        let tempDate = "2017-03-17T10:44:00+0000"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let startdate = dateFormatter.date(from:tempDate)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: startdate)
        let today = Date()
        let todaycomponents = calendar.dateComponents([.year, .month, .day, .hour], from: startdate)

        let finalDate = calendar.date(from:todaycomponents)
        print ("Start date: \(finalDate?.day())")
        print ("Start month: \(finalDate?.month())")

        var fitbarkpts:Int = 0
        print ("Start date: \(startdate)")
        let predicate = NSPredicate(format: "(slug BEGINSWITH %@) AND (date == %@)", dogslug, startdate as NSDate)
  //  let predicate = NSPredicate(format: "(slug BEGINSWITH %@) AND (date == %@)", dogslug, startdate )
    print ("Predicate \(predicate)")
    let query = CKQuery(recordType: "ActivityRecord", predicate: predicate)
    print ("Query: \(query)")
    publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
    if error != nil {
    print("Error querying records: \(error!.localizedDescription)")
    } else {
    if records!.count > 0 {
    //  let record = records!.first! as CKRecord
    // Now you have grabbed your existing record from iCloud
    print ("we have a record \(records)")
    for activity in records! {
    self.fitbptlist = activity.object(forKey: "fitbarkpts") as! [Int]
    
    print("Dog Owner  token date: \(activity["fitbarkpts"])")
    //   fitbptlist = Intactivity["fitbarkpts"]
    }
    print("List of points: \(self.fitbptlist)")
    // print("MInutes of active: \(self.minute_active_list)")
    for counter in self.fitbptlist {
    fitbarkpts = fitbarkpts + counter
    }
    
    // print ("Counter: \(fitbarkpts)")
    self.ptsvalue = fitbarkpts
    
    
    
    }
    else {
    //we have no records in icloud - so go get them from API
    print("else no records")
    self.fetchcalendaractivity(self.dogslug, startdate: startdate)
    }
    
    }
    })
    
    //if we already have saved it, we may want to see if it changed and modify it
    
}

    func fetchcalendaractivity(_ dogslug:String, startdate:Date) {
   //  func fetchcalendaractivity(_ dogslug:String, startdate:String) {
       /* URL: https://app.fitbark.com/api/v2/activity_series
         The maximum range is 42 days with daily resolution
         equest example 1
         {
         "activity_series":{
         "slug":"09659a8a-24c9-4246-92a8-7ecd0650368c",
         "from":"2013-03-02",
         "to":"2014-09-02",
         "resolution":"DAILY"
         }
         }
         Response example 1
         {
         "activity_series": {
         "slug": "09659a8a-24c9-4246-92a8-7ecd0650368c",
         "records": [
         {
         "date": "2014-12-27",
         "activity_value": 921,
         "min_play": 15,
         "min_active": 125,
         "min_rest": 1300,
         "daily_target": 5000,
         "has_trophy": 0
         },
         {
         "date": "2014-12-28",
         "activity_value": 5421,
         "min_play": 114,
         "min_active": 484,
         "min_rest": 838,
         "daily_target": 5000,
         "has_trophy": 1
 */
        // get current month 
        // get all the activities from the first of the month until the current date
        
        
        oauthswift.client.credential.oauthToken = WatchViewController.DogAuth.token
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd"
        let date1 = dayTimePeriodFormatter.string(from: startdate)
        let dogactivityURL = "https://app.fitbark.com/api/v2/activity_series"
        let jsonparameters = ["activity_series":
            ["slug": "\(dogslug)",
                "from":"\(date1)",
                "to":"\(date1)",
                "resolution":"DAILY"
            ]
        ]
        
        let _ = oauthswift.client.post(dogactivityURL, parameters: jsonparameters, headers: ["Content-Type":"application/json"], success: { response in
            let data = response.data
            let json = JSON(data: data) // convert network data to json
            //Getting an array of string from a JSON Array
            let activity =  json["activity_series"]
            // print ("Activity: \(activity)")
            let activityValues =  activity["records"].arrayValue.map({$0["activity_value"].intValue})
            print ("Activity values: \(activityValues)")
            self.fitbptlist = activityValues    // the fitbark points we received for each day
            print ("Points for the day: \(self.ptsvalue)")
            //save daily points
          //  self.SaveDogActivity(dogslug, startdate: startdate)
            
            
        },
                                       failure: { error in
                                        print(error.description)
        }
        )
        

            
    }
    

}
