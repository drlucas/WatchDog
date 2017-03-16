//
//  DogDetailsViewController.swift
//  WatchDog
//
//  Created by Ryan Lucas on 3/1/17.
//  Copyright © 2017 Ryan Lucas. All rights reserved.
//

import UIKit
import CloudKit
import Charts
import OAuthSwift



class ChartFormatter:NSObject,IAxisValueFormatter{
    
   // var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
   // var hours: [String]! = ["12am" , "1am", "2am", "3am", "4am", "5am", "6am", "7am", "8am", "9am", "10am", "11am", "12pm" , "1pm", "2pm", "3pm", "4pm", "5pm", "6pm", "7pm", "8pm", "9pm", "10pm", "11pm"]
    
    // The array of values to show on x axis
   private var myArr: [String]!
   init(myArr: [String]) {
        self.myArr = myArr
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let val = Int(value)
        if val >= 0 && val <= myArr.count {
            return myArr[Int(val)]
        }
        
        return ""
    }
    
    //func stringForValue(_ value: Double, axis: AxisBase?) -> String {
   //     return hours[Int(value)]
   // }
}


class DogDetailsViewController: UIViewController, EPCalendarPickerDelegate, ChartViewDelegate {
    
    
    required init?(coder aDecoder: NSCoder) {
       // self.authtoken = ""
       // self.barkpoints : UILabel
        super.init(coder: aDecoder)
    }
    
    
    let publicDB = CKContainer.default().publicCloudDatabase
    //var userrecord:CKRecordID!
    //let OwnerRecord = CKRecord(recordType: "Owners")
    //var credentials:String!
    let oauthswift = OAuth2Swift(
        consumerKey:    "fdcb4ac3295906a977f6317979ffaab6d11d93e833c1f41ed834c2b0908cdf2c",
        consumerSecret: "4ca58af6e0b5c9188d17fc92366c86b8f1f4c8bd9e77ef847edc6479487ef120",
        authorizeUrl:   "https://app.fitbark.com/oauth/authorize",
        accessTokenUrl: "https://app.fitbark.com/oauth/token",
        responseType:   "code"
    )
    var dogbirthday:Date!  // dateFormatter.dateFormat = "yyyy-MM-dd"
    var dogslug:String! // the slug for the dog
    var date1:Date!
    var date2:Date!
    var fitbptlist:[Int] = []   // the fitbark points we received for each hour
    var minute_active_list:[Int] = []  //the number of minutes active each hour
    var minute_play_list:[Int] = []  //the number of minutes playing each hour
    var date_time_list: [String] =  []
    var minute_rest_list:[Int] = []  //the number of minutes resting each hour
    var ptsvalue = 0
    var minresttotal = 0
    var minacttotal = 0
    var minplaytotal = 0
    
     //  var authtoken = ""
   // var barkpoints : UILabel // hold
    
    @IBOutlet weak var endingdate: UILabel!
    @IBOutlet weak var startingdate: UILabel!
    @IBOutlet weak var DogsAgeLabel: UILabel!
    
    @IBOutlet weak var RestTotal: UILabel!
    @IBOutlet weak var ActiveTotal: UILabel!
    @IBOutlet weak var PlayTotal: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var ChartType: UISegmentedControl!  // 0 = bar, 1 = line
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("Into the details controller for the dog - bday = \(self.dogbirthday)")
        checkbirthdate()
        // Do any additional setup after loading the view.
        // print("The user's dogs slug is: \(dogslug) ")
        date1 = dogbirthday
        date2 = Date()
        GetDailyActivity(dogslug, startdate:date1, enddate:date2 )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Navigation

 

    func checkbirthdate() {
        let birthDate = dogbirthday!
        let dcf = DateComponentsFormatter()
        dcf.allowedUnits = .year
        dcf.unitsStyle = .full
        let age = dcf.string(from: birthDate, to: Date())
        print("Your dogs age is \(age)")
        DogsAgeLabel.text = age
       
        let now = Date()
        let calendar = NSCalendar.current
        let birthdayDay = calendar.component(.day, from: dogbirthday as Date)
        let birthdayMonth = calendar.component(.month, from: dogbirthday as Date)
        let thisYearDay  = calendar.component(.day, from: now as Date)
        let thisYearMonth = calendar.component(.month, from: now as Date)
        if (birthdayDay == thisYearDay) && (birthdayMonth == thisYearMonth) {
            print ("Happy birthday!!!!")
        } else {
            print ("It is not your birth day yet")
        }
    
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.includesApproximationPhrase = true
        formatter.includesTimeRemainingPhrase = true
        formatter.allowedUnits = [.minute]
        
        // Use the configured formatter to generate the string.
        let outputString = formatter.string(from: 300.0)
        print (outputString)
    }
    
    
    func GetDailyActivity(_ dogslug:String, startdate:Date, enddate:Date) {
                
        //Get activity information from icloud
        //if we don't have an icloud record for this date/range then get from fitbark api and save to icloud
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        var fitbarkpts:Int = 0
        print ("Start date: \(startdate)")
    
        let predicate = NSPredicate(format: "(slug BEGINSWITH %@) AND (date == %@)", dogslug, startdate as NSDate)
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
                        self.minute_active_list = activity.object(forKey: "minute_active_list") as! [Int]
                        self.minute_rest_list = activity.object(forKey: "minute_rest_list") as! [Int]
                        self.minute_play_list = activity.object(forKey: "minute_play_list") as! [Int]
                        
                          print("Dog Owner  token date: \(activity["fitbarkpts"])")
                        //   fitbptlist = Intactivity["fitbarkpts"]
                    }
                    print("List of points: \(self.fitbptlist)")
                    // print("MInutes of active: \(self.minute_active_list)")
                    for counter in self.fitbptlist {
                        fitbarkpts = fitbarkpts + counter
                    }
                    
                    for hours in self.minute_active_list {
                        self.minacttotal = self.minacttotal + hours
                    }
                    
                    for hours in self.minute_rest_list {
                        self.minresttotal = self.minresttotal + hours
                    }
                    
                    for hours in self.minute_play_list {
                        self.minplaytotal = self.minplaytotal + hours
                    }
                    
                    // print ("Counter: \(fitbarkpts)")
                    self.ptsvalue = fitbarkpts
                    
                    
                    
                }
                else {
                    //we have no records in icloud - so go get them from API
                    print("else no records")  // GetDailyActivity(dogslug, startdate: self.date1, enddate: self.date2)
                    //self.fetchpoints(dogslug, startdate: startdate, enddate: enddate)
                    self.fetchcalendaractivity(dogslug, startdate: startdate, enddate: enddate)
                }
                
            }
        })
        
        //if we already have saved it, we may want to see if it changed and modify it
    
    }
   
    func fetchcalendaractivity(_ dogslug:String, startdate:Date, enddate:Date) {
        print ("Fetch activity")
    /*
     let date1 = dayTimePeriodFormatter.string(from: thedate)
     let dogactivityURL = "https://app.fitbark.com/api/v2/activity_series"
     let jsonparameters = ["activity_series":
     ["slug": "\(dogslug)",
     "from":"\(date1)",
     "to":"\(date1)",
     "resolution":"HOURLY"
     ]
     ]
        
         Jason: Optional({
         "activity_series" =     {
         records =         (
         {
         "activity_value" = 1329;
         date = "2017-03-09 00:00:00";
         "distance_in_miles" = "0.19";
         kcalories = 35;
         "min_active" = 12;
         "min_play" = 4;
         "min_rest" = 44;
         },
         {
         "activity_value" = 59;   ........
     
    
 
 */
        
        
        oauthswift.client.credential.oauthToken = WatchViewController.DogAuth.token
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd"
        let date1 = dayTimePeriodFormatter.string(from: startdate)
        let dogactivityURL = "https://app.fitbark.com/api/v2/activity_series"
        let jsonparameters = ["activity_series":
            ["slug": "\(dogslug)",
                "from":"\(date1)",
                "to":"\(date1)",
                "resolution":"HOURLY"
            ]
        ]
        
        //https://github.com/SwiftyJSON/SwiftyJSON thank you SwiftyJSON
        
        let _ = oauthswift.client.post(dogactivityURL, parameters: jsonparameters, headers: ["Content-Type":"application/json"], success: { response in
            let data = response.data
            let json = JSON(data: data) // convert network data to json
            //Getting an array of string from a JSON Array
            let activity =  json["activity_series"]
           // print ("Activity: \(activity)")
            let activityValues =  activity["records"].arrayValue.map({$0["activity_value"].intValue})
            print ("Activity values: \(activityValues)")
            let activeValues =  activity["records"].arrayValue.map({$0["min_active"].intValue})
            print ("Active values: \(activeValues)")
            let playValues =  activity["records"].arrayValue.map({$0["min_play"].intValue})
            print ("Play values: \(playValues)")
            let restValues =  activity["records"].arrayValue.map({$0["min_rest"].intValue})
            print ("Rest values: \(restValues)")
            let dateValues =  activity["records"].arrayValue.map({$0["date"].stringValue})
            print ("Date values: \(dateValues)")
            self.fitbptlist = activityValues    // the fitbark points we received for each hour
            self.minute_active_list = activeValues  //the number of minutes active each hour
            self.minute_play_list = playValues  //the number of minutes playing each hour
            self.date_time_list = dateValues
            self.minute_rest_list = restValues //the number of minutes resting each hour
            //let total = items.reduce(10.0,combine: +)  //https://useyourloaf.com/blog/swift-guide-to-map-filter-reduce/
            self.ptsvalue =  self.fitbptlist.reduce(0, +)
            print ("Points for the day: \(self.ptsvalue)")
            self.minplaytotal = self.minute_play_list.reduce(0,+)
            var hours = self.minplaytotal / 60 % 24
            var minutes = self.minplaytotal % 60
            self.PlayTotal.text = String(format:"%02i:%02i", hours, minutes)
            self.minacttotal = self.minute_active_list.reduce(0,+)
            hours =  self.minacttotal / 60 % 24
            minutes =  self.minacttotal % 60
            self.ActiveTotal.text = String(format:"%02i:%02i", hours, minutes)
            print ("Active: TOtal - \(self.ActiveTotal.text)")
            self.minresttotal = self.minute_rest_list.reduce(0,+)
            hours =  self.minresttotal / 60 % 24
            minutes =  self.minresttotal % 60
            self.RestTotal.text = String(format:"%02i:%02i", hours, minutes)
            //save daily points
            self.SaveDogActivity(dogslug, startdate: startdate)
            
            
        },
                                       failure: { error in
                                        print(error.description)
        }
        )
    
    }
    
    func SaveDogActivity(_ dogslug:String, startdate:Date) {
        /*
         Save back to cloudkit
         */
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        print ("Start date: \(startdate)")
        let predicate = NSPredicate(format: "(slug BEGINSWITH %@) AND (date == %@)", dogslug, startdate as NSDate)
        print ("Predicate \(predicate)")
        let query = CKQuery(recordType: "ActivityRecord", predicate: predicate)
        print ("Query: \(query)")
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                print("Error querying records: \(error!.localizedDescription)")
            } else {
                if records!.count > 0 {
                    let record = records!.first! as CKRecord
                    // Now you have grabbed your existing record from iCloud
                            print("Successfully got the record from icloud, so we don't need to save a new record")
                }
                
                else {
                    print ("No records")
                        // we don't have any records that match the dog slug - so save it
                        let dogRecord = CKRecord(recordType: "ActivityRecord")
                        dogRecord["date"] = startdate as CKRecordValue? //Date() as CKRecordValue?
                        dogRecord["fitbarkpts"] = self.fitbptlist as CKRecordValue?
                        dogRecord["minute_active_list"] = self.minute_active_list as CKRecordValue?
                        dogRecord["minute_play_list"] = self.minute_play_list as CKRecordValue?
                        dogRecord["minute_rest_list"] = self.minute_rest_list as CKRecordValue?
                        dogRecord["slug"] = dogslug as CKRecordValue?
                        self.publicDB.save(dogRecord, completionHandler: ({returnRecord, error in
                            if let err = error {
                                print("Error saving record for owner \(err)")
                                
                            }
                            else {
                                //self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                                print("Dog  saved \(dogRecord["name"])")
                            }
                        }))
                }
            }

                }
        
        )
    }
    

    
    
    func fetchpoints(_ dogslug:String, startdate:Date, enddate:Date) {
        /*
 //get dog activity based on two dates https://app.fitbark.com/api/v2/activity_series
 {"activity_series":{
 "slug":"1ba28be9-4e9e-4583-b7d8-b6bb84b17da7",  //Archie's slug
 "from":"2013-03-02",
 "to":"2014-09-02",
 "resolution":"DAILY"
 }}
 {"activity_series" =     {
 records =         (
 {
 "activity_value" = 49;
 date = "2016-04-01 00:00:00";
 "min_active" = 13;
 
 ActivityRecord (cloudkit record format - )
 activity_list - Int(64) List
 date - Date/Time
 minute_activity_list - Int(64) List
 minute_play_list - Int(64) List
 minute_rest_list - Int(64) List
 slug - String
 
 */

        // NEED SOME LOGIC TO SEE WHEN THE FITBARK LAST SYNCED  - maybeone day get the watch to pull from the dongle
      //  self.barkpoints.text = "0"
        var fitbarkpoints = -1
        var lastsync = "2014-08-31T17:17:54.000Z"
        print ("Token::::::: \(WatchViewController.DogAuth.token)")
        oauthswift.client.credential.oauthToken = WatchViewController.DogAuth.token
        //WatchViewController self.authtoken
        //https://app.fitbark.com/api/v2/dog/{dog_slug}
        let dogURL = "https://app.fitbark.com/api/v2/dog/\(dogslug)"
        
        let _ = oauthswift.client.get(dogURL, parameters: [:], success: { response in
            let jsonDict = try? response.jsonObject() as AnyObject!
            let ourdogfromfitbark = jsonDict?["dog"] as! NSDictionary?
            //print (ourdogfromfitbark)
            fitbarkpoints = (ourdogfromfitbark!["activity_value"] as! Int?)!
            lastsync = (ourdogfromfitbark!["last_sync"] as! String?)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let lastDate = dateFormatter.date(from: lastsync)
            let todayDate = NSDate()
            let currentCalendar = Calendar.current
            let start = currentCalendar.ordinality(of: .day, in: .era, for: lastDate!)
            let end = currentCalendar.ordinality(of: .day, in: .era, for: todayDate as Date)
            let daysbetween = (end! - start!)
            print ("Days since last synced = \(daysbetween)")
            print("Date: \(todayDate)")
            print ("Last sync: \(lastsync)")
            print ("Fit bark points: \(fitbarkpoints)")
         /*   DispatchQueue.main.async {
                self.barkpoints.text  = "\(fitbarkpoints)"
                //send the points to the watch to display
                
                let msg = ["StringValueSentFromiWatch" : self.barkpoints.text]
                self.session?.sendMessage(msg, replyHandler: { (replay) -> Void in
                    print("apple watch sent")
                }) { (error) -> Void in
                print("apple watch sent error \(error)")
                }
                
            }*/
        },
                                      failure: { error in
                                        print(error.description)
        }
        )
    
    
    }  // done fetching current barkpoints
    


    
    @IBAction func graphactivites(_ sender: UIButton) {
        if ChartType.selectedSegmentIndex == 0  {  //bar
            bargraph()
            }
        else {   //line
            linegraph()
            }
        }
    
     func bargraph () {
        lineChartView.isHidden = true
        barChartView.isHidden = false
        print ("Bar Graph dog activity level")
        let hours = ["12am" , "1am", "2am", "3am", "4am", "5am", "6am", "7am", "8am", "9am", "10am", "11am", "12pm" , "1pm", "2pm", "3pm", "4pm", "5pm", "6pm", "7pm", "8pm", "9pm", "10pm", "11pm"]
        let formato:ChartFormatter = ChartFormatter(myArr: hours)
        let xaxis:XAxis = XAxis()
        
        var bar1 = [Double]()  //list of min active  moved from INT to double
        var bar2 = [Double]()  //list of minutes of rest
        var bar3 = [Double]()  //list of minutes of play
        
        for item in self.minute_active_list {
            bar1.append(Double(item))
        }
        for item in self.minute_rest_list {
            bar2.append(Double(item))
        }
        for item in self.minute_play_list {
            bar3.append(Double(item))
        }
        
        barChartView.delegate = self
     //   barChartView.descriptionText = "Tap node for details"
     //   barChartView.descriptionTextColor = UIColor.white
        barChartView.noDataText = "No data loaded"
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawBordersEnabled = false
        
        // 1 - creating an array of data entries
        var yVals1: [ChartDataEntry] = Array()
        for (i, value) in bar1.enumerated()
        {
            yVals1.append(BarChartDataEntry(x: Double(i), y: value))
        }
        let set1: BarChartDataSet = BarChartDataSet(values: yVals1, label: "Minutes Active")
        set1.axisDependency = .left // Bar will correlate with left axis values
        set1.setColor(UIColor.red.withAlphaComponent(0.5))
        set1.highlightColor = UIColor.white
        
        var yVals2: [ChartDataEntry] = Array()
        for (i, value) in bar2.enumerated()
        {
            yVals2.append(BarChartDataEntry(x: Double(i), y: value))
        }
        let set2: BarChartDataSet = BarChartDataSet(values: yVals2, label: "Minutes Resting")
        set2.axisDependency = .left // Bar will correlate with left axis values
        set2.setColor(UIColor.green.withAlphaComponent(0.5))
        set2.highlightColor = UIColor.white
        
        var yVals3: [ChartDataEntry] = Array()
        for (i, value) in bar3.enumerated()
        {
            yVals3.append(BarChartDataEntry(x: Double(i), y: value))
        }
        let set3: BarChartDataSet = BarChartDataSet(values: yVals3, label: "Minutes Playing")
        set3.axisDependency = .left // Bar will correlate with left axis values
        set3.setColor(UIColor.blue.withAlphaComponent(0.5))
        set3.highlightColor = UIColor.white
        
          //3 - create an array to store our  BarChartDataSets
        var dataSets : [BarChartDataSet] = [BarChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        dataSets.append(set3)

        barChartView.leftAxis.axisMinimum = 0.0
        barChartView.rightAxis.axisMinimum = 0.0
        barChartView.leftAxis.axisMaximum = 60.0
        barChartView.rightAxis.axisMaximum = 60
      //  barChartView.xAxis.granularityEnabled = true
     //   barChartView.xAxis.granularity = 1.0 //default granularity is 1.0, but it is better to be explicit
     //   barChartView.xAxis.decimals = 0
        //4 - pass our months in for our x-axis label value along with our dataSets
    
        let chartData = BarChartData(dataSets: dataSets)
        chartData.barWidth = 0.85
        let format = NumberFormatter()
        format.numberStyle = .none  //.decimal
        let formatter = DefaultValueFormatter(formatter: format)
        chartData.setValueFormatter(formatter)
        //5 - finally set our data
        barChartView.data = chartData

    }
    
    func linegraph () {
        print ("Line Graph dog activity level")
        lineChartView.isHidden = false
        barChartView.isHidden = true
       // print ("Chart type: \(ChartType.selectedSegmentIndex)")

        let hours = ["12am" , "1am", "2am", "3am", "4am", "5am", "6am", "7am", "8am", "9am", "10am", "11am", "12pm" , "1pm", "2pm", "3pm", "4pm", "5pm", "6pm", "7pm", "8pm", "9pm", "10pm", "11pm"]
        let formato:ChartFormatter = ChartFormatter(myArr: hours)
        let xaxis:XAxis = XAxis()
        
 //       var line4 = [Double]()  //list of fitbark points moved from INT to double
        var line1 = [Double]()  //list of min active  moved from INT to double
        var line2 = [Double]()  //list of minutes of rest
        var line3 = [Double]()  //list of minutes of play
        
        for item in self.minute_active_list {
            line1.append(Double(item))
        }
        for item in self.minute_rest_list {
            line2.append(Double(item))
        }
        for item in self.minute_play_list {
            line3.append(Double(item))
        }

    
        lineChartView.delegate = self
      //  lineChartView.descriptionText = "Tap node for details"
      //  lineChartView.descriptionTextColor = UIColor.white
        //lineChartView.gridBackgroundColor = UIColor.white
        lineChartView.noDataText = "No data loaded"
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.drawBordersEnabled = false
    
        // 1 - creating an array of data entries
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< hours.count {
            yVals1.append(ChartDataEntry(x:Double(i), y:line1[i]))
            formato.stringForValue(Double(i), axis: xaxis)
           //chartFormmater.stringForValue(Double(i), axis: xAxis)
        }//
       
 //(x: Double(i)
        let set1: LineChartDataSet = LineChartDataSet(values: yVals1, label: "Minutes Active")
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(UIColor.red.withAlphaComponent(0.5))
       // set1.setCircleColor(UIColor.red)
        set1.lineWidth = 2.0
        set1.circleRadius = 0
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.red
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true
        
       var yVals2 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< hours.count {
            yVals2.append(ChartDataEntry(x: Double(i), y: line2[i]))
             formato.stringForValue(Double(i), axis: xaxis)
            
        }
        
        let set2: LineChartDataSet = LineChartDataSet(values: yVals2, label: "Minutes Resting")
        set2.axisDependency = .left // Line will correlate with left axis values
       set2.setColor(UIColor.green.withAlphaComponent(0.5))
     //   set2.setCircleColor(UIColor.green)
        set2.lineWidth = 2.0
        set2.circleRadius = 0
        set2.fillAlpha = 65 / 255.0
        set2.fillColor = UIColor.green
        set2.highlightColor = UIColor.white
       set2.drawCircleHoleEnabled = true
        
        var yVals3 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< hours.count {
            yVals3.append(ChartDataEntry(x: Double(i), y: line3[i]))
             formato.stringForValue(Double(i), axis: xaxis)
            
        }
        
        let set3: LineChartDataSet = LineChartDataSet(values: yVals3, label: "Minutes Playing")
        set3.axisDependency = .left // Line will correlate with left axis values
        set3.setColor(UIColor.blue.withAlphaComponent(0.5))
       // set3.setCircleColor(UIColor.blue)
       set3.lineWidth = 2.0
        set3.circleRadius = 0
        set3.fillAlpha = 65 / 255.0
        set3.fillColor = UIColor.blue
        set3.highlightColor = UIColor.white
        set3.drawCircleHoleEnabled = true
    
 
        //3 - create an array to store our LineChartDataSets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        dataSets.append(set3)
        
        //yAxis.drawAxisLineEnabled = false
        //yAxis.drawGridLinesEnabled = false
        
        lineChartView.leftAxis.axisMinimum = 0.0
        lineChartView.rightAxis.axisMinimum = 0.0
        lineChartView.leftAxis.axisMaximum = 60.0
        lineChartView.rightAxis.axisMaximum = 60
        
        xaxis.valueFormatter = formato
        lineChartView.xAxis.valueFormatter = xaxis.valueFormatter
        //4 - pass our months in for our x-axis label value along with our dataSets
        // three lines of data....one for rest, active and play 
        // x -axis is going to hold the hours of the day and y - axis is value of each
        let chartData = LineChartData(dataSets: dataSets)
     
        /*
         
        
 */
        
        
   //     xAxis.valueFormatter=chartFormmater
   //     lineChartView.xAxis.valueFormatter=xAxis.valueFormatter
        //5 - finally set our data
        lineChartView.data = chartData
        
    }

    
    
    @IBAction func showcalendar(_ sender: UIButton) {
        print ("show calendar")
        let calendarPicker = EPCalendarPicker(startYear: 2016, endYear: 2017, multiSelection: true, selectedDates: [])
        calendarPicker.calendarDelegate = self
        // calendarPicker.startDate = NSDate()
        calendarPicker.hightlightsToday = true
        calendarPicker.showsTodaysButton = true
        calendarPicker.hideDaysFromOtherMonth = true
        calendarPicker.tintColor = UIColor.orange
        //        calendarPicker.barTintColor = UIColor.greenColor()
        calendarPicker.dayDisabledTintColor = UIColor.gray
        calendarPicker.title = "Activity Selection"
        //        calendarPicker.backgroundImage = UIImage(named: "background_image")
        //        calendarPicker.backgroundColor = UIColor.blueColor()
        let navigationController = UINavigationController(rootViewController: calendarPicker)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError) {
        print ( "User cancelled selection")
        
    }
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : Date) {
        print ("User selected date: \n\(date)")
        
    }
    func epCalendarPicker(_: EPCalendarPicker, didSelectMultipleDate dates : [Date]) {
        if (dates.count != 2) {
            print ("ERROR more than 2 dates")
        }
        else
        {
            
            self.date1 = dates[0]
            self.date2 = dates[1]
            
 
             let startDateComparisionResult:ComparisonResult = dates[0].compare((dates[1] as NSDate) as Date)
             
             if startDateComparisionResult == ComparisonResult.orderedAscending
             {
             // Current date is smaller than end date.
             startingdate.text = String(describing: dates[0])
             endingdate.text = String(describing: dates[1])
             }
             else if startDateComparisionResult == ComparisonResult.orderedDescending
             {
             // Current date is greater than end date.
             startingdate.text = String(describing: dates[1])
             endingdate.text = String(describing: dates[0])
             self.date1 = dates[1]
             self.date2 = dates[0]

             }
             else if startDateComparisionResult == ComparisonResult.orderedSame
             {
             // Current date and end date are same
             
             }
 
             print ( "User selected dates: \(startingdate.text) and \(endingdate.text)") 
            GetDailyActivity(dogslug, startdate: self.date1, enddate: self.date2)
            }
        
    }
    
/*
func grapha(_ sender: UIButton) {
        print ("Graph dog activity level")
        print ("Chart type: \(ChartType.selectedSegmentIndex)")
        
        let hours = ["12am" , "1am", "2am", "3am", "4am", "5am", "6am", "7am", "8am", "9am", "10am", "11am", "12pm" , "1pm", "2pm", "3pm", "4pm", "5pm", "6pm", "7pm", "8pm", "9pm", "10pm", "11pm"]
        let formato:ChartFormatter = ChartFormatter(myArr: hours)
        let xaxis:XAxis = XAxis()
        
        //       var line4 = [Double]()  //list of fitbark points moved from INT to double
        var line1 = [Double]()  //list of min active  moved from INT to double
        var line2 = [Double]()  //list of minutes of rest
        var line3 = [Double]()  //list of minutes of play
        
        for item in self.minute_active_list {
            line1.append(Double(item))
        }
        for item in self.minute_rest_list {
            line2.append(Double(item))
        }
        for item in self.minute_play_list {
            line3.append(Double(item))
        }
        
        
        lineChartView.delegate = self
        lineChartView.descriptionText = "Tap node for details"
        lineChartView.descriptionTextColor = UIColor.white
        //lineChartView.gridBackgroundColor = UIColor.white
        lineChartView.noDataText = "No data provided"
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.drawBordersEnabled = false
        
        // 1 - creating an array of data entries
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< hours.count {
            yVals1.append(ChartDataEntry(x:Double(i), y:line1[i]))
            formato.stringForValue(Double(i), axis: xaxis)
            //chartFormmater.stringForValue(Double(i), axis: xAxis)
        }//
        
        //(x: Double(i)
        let set1: LineChartDataSet = LineChartDataSet(values: yVals1, label: "Minutes Active")
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(UIColor.red.withAlphaComponent(0.5))
        // set1.setCircleColor(UIColor.red)
        set1.lineWidth = 2.0
        set1.circleRadius = 0
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.red
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true
        
        var yVals2 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< hours.count {
            yVals2.append(ChartDataEntry(x: Double(i), y: line2[i]))
            formato.stringForValue(Double(i), axis: xaxis)
            
        }
        
        let set2: LineChartDataSet = LineChartDataSet(values: yVals2, label: "Minutes Resting")
        set2.axisDependency = .left // Line will correlate with left axis values
        set2.setColor(UIColor.green.withAlphaComponent(0.5))
        //   set2.setCircleColor(UIColor.green)
        set2.lineWidth = 2.0
        set2.circleRadius = 0
        set2.fillAlpha = 65 / 255.0
        set2.fillColor = UIColor.green
        set2.highlightColor = UIColor.white
        set2.drawCircleHoleEnabled = true
        
        var yVals3 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< hours.count {
            yVals3.append(ChartDataEntry(x: Double(i), y: line3[i]))
            formato.stringForValue(Double(i), axis: xaxis)
            
        }
        
        let set3: LineChartDataSet = LineChartDataSet(values: yVals3, label: "Minutes Playing")
        set3.axisDependency = .left // Line will correlate with left axis values
        set3.setColor(UIColor.blue.withAlphaComponent(0.5))
        // set3.setCircleColor(UIColor.blue)
        set3.lineWidth = 2.0
        set3.circleRadius = 0
        set3.fillAlpha = 65 / 255.0
        set3.fillColor = UIColor.blue
        set3.highlightColor = UIColor.white
        set3.drawCircleHoleEnabled = true
        
        
        //3 - create an array to store our LineChartDataSets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        dataSets.append(set3)
        
        //yAxis.drawAxisLineEnabled = false
        //yAxis.drawGridLinesEnabled = false
        
        lineChartView.leftAxis.axisMinimum = 0.0
        lineChartView.rightAxis.axisMinimum = 0.0
        lineChartView.leftAxis.axisMaximum = 60.0
        lineChartView.rightAxis.axisMaximum = 60
        
        xaxis.valueFormatter = formato
        lineChartView.xAxis.valueFormatter = xaxis.valueFormatter
        //4 - pass our months in for our x-axis label value along with our dataSets
        // three lines of data....one for rest, active and play
        // x -axis is going to hold the hours of the day and y - axis is value of each
        let chartData = LineChartData(dataSets: dataSets)
        
        /*
         
         
         */
        
        
        //     xAxis.valueFormatter=chartFormmater
        //     lineChartView.xAxis.valueFormatter=xAxis.valueFormatter
        //5 - finally set our data
        lineChartView.data = chartData
        
    }
    
*/
    
    
}// end of class


/* 
 
 
 @IBOutlet var playvalue: UILabel!
 @IBOutlet var activevalue: UILabel!
 @IBOutlet var restvalue: UILabel!
 @IBOutlet var ptsleftvalue: UILabel!
 @IBOutlet var targetvaluelabel: UILabel!   //done
 @IBOutlet var ptsvaluelabel: UILabel!      //done
 @IBOutlet var percentagelabel: UILabel!    //done
 var targetvalue = 0
 var percentcomplete:Double!
 var ptsvalue = 0
 var minresttotal = 0
 var minacttotal = 0
 var minplaytotal = 0
 var dogslug:String! // the string for the user that was passed over from previous controller
 let publicDB = CKContainer.default().publicCloudDatabase
 var startdate:Date!  //start date for daily activity
 var enddate:Date! //end date for daily activity that was passed

 override func viewDidLoad() {
  // Do any additional setup after loading the view.
 Timer.scheduledTimer(timeInterval: 3.0, target: self,
 selector: #selector(DogDailyChart.updateData), userInfo: nil, repeats: true)
 
 
 // print("The user's dogs slug is: \(dogslug) ")
 GetDailyActivity(dogslug, startdate:startdate, enddate:enddate )
 getDailyGoals ()
 drawCircle()
 
 }
  /*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
 
 
 drawcir
 
 
 
 
 func getDailyGoals () // need to use an input of dogslug {
 {
 print ("Get dog's current daily and future goals")
 var daily_goals = [DailyGoal] () // an array that will contain all our daily goals
 let predicate = NSPredicate(format: "slug BEGINSWITH %@", dogslug)
 let query = CKQuery(recordType: "Dogs", predicate: predicate)
 print ("Query: \(query)")
 publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
 if error != nil {
 print("Error querying records: \(error!.localizedDescription)")
 } else {
 if records!.count > 0 {
 //print ("we have a record \(records)")
 for goals in records! {
 // fitbptlist = activity.objectForKey:"fitbarkptsfitbptlist")
 var goallist = goals.object(forKey: "daily_goals") as! [String]
 // print("Dog Goals: \(goallist[0])")
 
 self.targetvalue = Int(goallist[0])!
 }
 
 
 }
 else {
 //we have no records
 }
 
 }
 })  }
 
 
 
 
 func updateData () {
 //all this does is update a lable
 self.targetvaluelabel.text = String(self.targetvalue)
 self.ptsvaluelabel.text = String(ptsvalue)
 
 if self.targetvalue > 0 {
 
 percentcomplete = Double((Double(self.ptsvalue) / Double(self.targetvalue)) * 100)
 self.percentagelabel.text = String(self.percentcomplete)
 self.playvalue.text = String(self.minplaytotal)
 self.activevalue.text = String(self.minacttotal)
 self.restvalue.text = String(self.minresttotal)
 view.bringSubview(toFront: self.percentagelabel)
 // print ("\(percentcomplete) \(self.ptsvalue) \(self.targetvalue)")
 }
 
 }
 }

 
 */
