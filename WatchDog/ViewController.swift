//
//  ViewController.swift
//  WatchDog
//
//  Created by Ryan Lucas on 12/31/16.
//  Copyright © 2016 Ryan Lucas. All rights reserved.
//

//  Created by Dongri Jin on 6/21/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//

import OAuthSwift
import CloudKit
import WatchConnectivity

class ViewController: OAuthViewController , WCSessionDelegate {

    var string = "Hello World"
    let session: WCSession? = WCSession.isSupported() ? WCSession.default() : nil
    
    @IBAction func LoginButton(_ sender: UIButton) {
        print ("Login pushed")
        checkUserExists()
        DispatchQueue.global(qos: .background).async {
            self.doOAuthFitBark()
        }
        print ("done logging in")
        // getuserslug()
    }
    
    @IBAction func getslugbutton(_ sender: Any) {
        getuserslug()

    }
    
    
    
    @IBAction func getdogbutton(_ sender: Any) {
        FetchDogs()
    }
    
    @IBAction func getuserimagebtn(_ sender: Any) {
        print ("get the image")
    }
   
    @IBAction func getdogimagebtn(_ sender: Any) {
        print ("get the dog image")
        getdogimage()
    }
    
    @IBAction func pingwatch(_ sender: Any) {
        print ("send watch a text")
        let msg = ["StringValueSentFromiWatch" : "GOT IT"]
        session?.sendMessage(msg, replyHandler: { (replay) -> Void in
            print("apple watch sent")
        }) { (error) -> Void in
            print("apple watch sent error \(error)")
        }

    }
    
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        let msg = message["StringValueSentFromiWatch"] as! String
        print ("Message received: \(msg)")
        DispatchQueue.main.async {
            self.watchmessage.text = msg

        }
        
    
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    @IBAction func saveuserbutton(_ sender: Any) {
        SaveOwnerRecord() 
    }
   
    @IBOutlet weak var dogcountlabel: UILabel!
    
    @IBOutlet weak var dogimageview: UIImageView!
    @IBOutlet weak var userimageview: UIImageView!
    @IBOutlet weak var watchmessage: UILabel!

    
    
    
    let oauthswift = OAuth2Swift(
        consumerKey:    "fdcb4ac3295906a977f6317979ffaab6d11d93e833c1f41ed834c2b0908cdf2c",
        consumerSecret: "4ca58af6e0b5c9188d17fc92366c86b8f1f4c8bd9e77ef847edc6479487ef120",
        authorizeUrl:   "https://app.fitbark.com/oauth/authorize",
        accessTokenUrl: "https://app.fitbark.com/oauth/token",
        responseType:   "code"
    )

    var dogimageviewpointer = 0
    var currentParameters = [String: String]()
    let formData = Semaphore<FormViewControllerData>()
    lazy var internalWebViewController: WebViewController = {
        let controller = WebViewController()
        controller.view = UIView(frame: UIScreen.main.bounds) // needed if no nib or not loaded from storyboard
        controller.delegate = self
        controller.viewDidLoad() // allow WebViewController to use this ViewController as parent to be presented
        return controller
    }()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    var userrecord:CKRecordID!
    let OwnerRecord = CKRecord(recordType: "Owners")
    var credentials:String!
    let debug = true   // used to print debug info to the All output screen
    var authtoken = "" as String! // my authentication token to use in fitbark
    var firstname = "" as String!
    var lastname = "" as String!
    var tokendate:Date! //date when token was originally created
    //var userslug = "" as String! // my users slug from fitbark
    var userslug:String = "" // my users slug from fitbark
    var slugs = [String]() // an array that matches the dog's slug so we can get other info about our dogs
    var dogs = [Dog]()  // an array of dog records - names/slugs/ages/etc that we get back from related dogs
    var dogsluglist = [String]() //an array of dog slugs that the user owns --> we are going to save to icloud
    
}

extension ViewController: OAuthWebViewControllerDelegate {
    
    func oauthWebViewControllerDidPresent() {
        
    }
    func oauthWebViewControllerDidDismiss() {
        
    }
    
    func oauthWebViewControllerWillAppear() {
        
    }
    func oauthWebViewControllerDidAppear() {
        
    }
    func oauthWebViewControllerWillDisappear() {
        
    }
    func oauthWebViewControllerDidDisappear() {
        // Ensure all listeners are removed if presented web view close
       // oauthswift?.cancel()
        oauthswift.cancel()

    }
}

extension ViewController {
    
    // MARK: - do authentification
    func doAuthService() {
        
        // Ask to user by showing form from storyboards
        self.formData.data = nil
        Queue.main.async { [unowned self] in
            self.performSegue(withIdentifier: Storyboards.Main.FormSegue, sender: self)
            // see prepare for segue
        }
        // Wait for result
        guard let data = formData.waitData() else {
            // Cancel
            return
        }
        
            doOAuthFitBark()
       
      
    }

func getdogimage() {
        // first I need to figure out what dog to get
        // assume we already registered and have a dog slug 
   
    //every time the load picture button is pressed, we display the next dog in our list of dogs
    
    self.dogimageviewpointer =  self.dogimageviewpointer + 1
    if self.dogimageviewpointer  >= self.dogsluglist.count {
        self.dogimageviewpointer = 0
    }
    self.dogcountlabel.text = "\((self.dogimageviewpointer  + 1)) of \(self.dogsluglist.count)"
    let predicate = NSPredicate(format: "(slug BEGINSWITH %@) ", self.dogsluglist[self.dogimageviewpointer])
    let query = CKQuery(recordType: "Dogs", predicate: predicate)
    //print ("Query: \(query)")
    publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
        if error != nil {
            print("Error querying records: \(error!.localizedDescription)")
        } else {
            if records!.count == 1 {
                // we have retrieved a dog record
                for dog in records! {
                    print("Dog Owner's slug: \(dog["slug"])")
                    let downloadedimage = dog["image"] as! CKAsset
                    DispatchQueue.main.async {
                        self.dogimageview.image = UIImage(contentsOfFile: downloadedimage.fileURL.path)
                        
                    }
                }
            }
        }
    })
    }
    
    
func getuserslug() {
    //use the auth token from icloud
    //login to fitbark API
    //parse out the user's slug from fitbark
    
    print ("getuserslug")
    oauthswift.client.credential.oauthToken = self.authtoken!
    let _ = oauthswift.client.get("https://app.fitbark.com/api/v2/user", parameters: [:], success: { response in
      let jsonDict = try? response.jsonObject() as AnyObject!
      let curr_user = jsonDict?["user"] as! NSDictionary?
      let slug = curr_user!["slug"] as? String
      self.firstname = curr_user!["first_name"] as? String
      self.lastname = curr_user!["last_name"] as? String
      self.userslug = slug!
      print ("Slug: \(self.userslug)")
    },
                failure: { error in
                print(error.description)
    }
    )
    
}

    
    
    
    
    func SaveDogRecord (_ dog2save:Dog) { //maybe in the future deal with passing a dog into here
        //func SaveDogRecord(_ dog2save: Dog) {
            /*SAVE*/
        
        //before i saave...make sure I don't already have that dog.... 
        
       
        let predicate = NSPredicate(format: "(slug BEGINSWITH %@) ", dog2save.slug)
        let query = CKQuery(recordType: "Dogs", predicate: predicate)
        //print ("Query: \(query)")
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                print("Error querying records: \(error!.localizedDescription)")
            } else {
                if records!.count == 0 {
                    // we don't have any records that match the dog slug - so save it
                    let dogRecord = CKRecord(recordType: "Dogs")
                    dogRecord["name"] = dog2save.name as CKRecordValue?
                    dogRecord["gender"] =  dog2save.gender as CKRecordValue?
                    dogRecord["last_sync"] = Date() as CKRecordValue?
                    dogRecord["owner_slug"] = dog2save.owner as CKRecordValue?
                    dogRecord["slug"] = dog2save.slug as CKRecordValue?
                    //dogRecord["image"] = dog2save.image as CKRecordValue?
                    //   dogRecord["birth"] = dog2save.birth
                    
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
        })
        
    }
    

    
func SaveOwnerRecord() {
        /*SAVE*/
        //     self.keychain["the_token_key"] = self.oauthswift.client.credential.oauth_token
        //      authtoken = self.oauthswift.client.credential.oauth_token
        OwnerRecord["first_name"] = self.firstname as CKRecordValue?
        OwnerRecord["last_name"] = self.lastname as CKRecordValue?
        OwnerRecord["token"] = self.authtoken as CKRecordValue?
        OwnerRecord["token_date"] = Date() as CKRecordValue?
        OwnerRecord["slug"] = self.userslug as CKRecordValue?
        publicDB.save(OwnerRecord, completionHandler: { [unowned self] (record, error) -> Void in
            DispatchQueue.main.async {
                if error == nil {
                    self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                    print("Token: \(self.authtoken)")
                    print(" Record saved")
                } else {
                    print("Error saving record for owner \(error)")
                }
            }
        })
    }
    
func doOAuthFitBark() {
    print ("Do auth fitbark - woof!")
    oauthswift.accessTokenBasicAuthentification = true
    oauthswift.authorizeURLHandler = internalWebViewController
    print( "Get params: \(oauthswift.parameters)")
     let state = generateState(withLength: 20)
     print ("State: \(state)")
    let _ = oauthswift.authorize(
        withCallbackURL: URL(string: "oauth-swift://oauth-callback/fitbark")!, scope: "", state: state,
        success: { credential, response, parameters in
            print("Credentials \(credential.oauthToken)")
            print ("Paramters: \(parameters)")
            print ("Response: \(response)")
            print ("State: \(state)")
            self.testFitBark(self.oauthswift)
            self.authtoken = credential.oauthToken
        },
     failure: { error in
        print("ERRRROR")
        //likely just got an auth code, but no token
        //let OwnerRecord = self.oauthswift?.client.credential.oauthToken
        let OwnerRecord = self.oauthswift.client.credential.oauthToken
        print ("OwnerRecord: \(OwnerRecord)")
     print(error.description)
     }
    )
    
 print ("Done getting access code")
    
 
     }
    
    
func testFitBark(_ oauthswift: OAuth2Swift) {
    print("Testing")
    let _ = oauthswift.client.get("https://app.fitbark.com/api/v2/user", parameters: [:], success: { response in
        let jsonDict = try? response.jsonObject()
        print(jsonDict as Any)
        },
     failure: { error in
        print(error.description)
        }
    )
}
    
    
func getusername() {
        // Check to see if user is logged into iCloud
        // Once logged in get user's record ID, first name and lastname
        // Call function checkUserExists to see if record exists in WatchDog icloud database so we can use that access token vs logging in manually
    
        let container = CKContainer.default()
        container.requestApplicationPermission(.userDiscoverability) { (status, error) in
            guard error == nil else {
                print ("Error: \(error)")
                return }
            
            if status == CKApplicationPermissionStatus.granted {
                if self.debug {
                    print ("I have permission to icloud")
                }
                    CKContainer.default().fetchUserRecordID { (record, error) in
                        guard let recordID = record else { return }
                        print ("Record name: \(recordID.recordName) ")
                        self.userrecord = recordID
                        CKContainer.default().discoverUserIdentity(withUserRecordID: record!, completionHandler: { (userID, error) in
                           // print(userID?.hasiCloudAccount)
                           // print(userID?.lookupInfo?.phoneNumber)
                           // print(userID?.lookupInfo?.emailAddress)
                           // print((userID?.nameComponents?.givenName)! + " " + (userID?.nameComponents?.familyName)!)
                            let firstName = (userID?.nameComponents?.givenName) ?? ""
                            let lastName = (userID?.nameComponents?.familyName) ?? ""
                            //print ("First name: \(firstName)")
                             self.checkUserExists()
                        })
                    }
                    
                    
                }
    }
    
} //end of getusername


func FetchDogs() {
    // log into Fitbark and get a list of all the dogs that are related to the user
    print ("Fetching Dogs from Fitbark")
    var ownerdogcount = 0
    var doglist = [String]()
    oauthswift.client.credential.oauthToken = self.authtoken!
    let _ = oauthswift.client.get("https://app.fitbark.com/api/v2/dog_relations", parameters: [:], success: { response in
    let data = response.string
    if let dataFromString = data?.data(using: .utf8, allowLossyConversion: false) {
        let json = JSON(data: dataFromString)
                for item in json["dog_relations"].arrayValue {
                   //         print("Name: \(item["dog"]["name"].stringValue)")
                    if ( item["status"].stringValue == "OWNER" ) {   //we only want my dogs, not friends
                        let dogname = item["dog"]["name"].stringValue
                        let dogslug = item["dog"]["slug"].stringValue
                        let dogweight = item["dog"]["weight"].int
                        let doggender = item["dog"]["gender"].stringValue
                        let dogbirth = item["dog"]["birth"].stringValue
                       //We only got user related dogs here...so we'd need to get the dog's full on details 
                        // to do that we need to query this...  https://app.fitbark.com/api/v2/picture/dog/{dog_slug} 
                        //let dogimage = item["dog"]["image"].stringValue
           
                        //tried to set an image and that didn't work nicely...
                      // let downloadedimage = item["dog"]["image"] as! CKAsset
               //       self.userimageview.image = UIImage( contentsOfFile: downloadedimage.fileURL.path)
                        
    
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        let dogbday = dateFormatter.date( from: dogbirth )
                       // print("Dog image: \(dogimage)")
                        //print("Dog weight: \(dogweight)")
                        let mydog = Dog(birth:dogbday!, gender:doggender, weight:dogweight!, name: dogname, slug:dogslug, image:"", owner:"")
                        // self.dogs[self.ownderdogcount].name = dogname
                        // self.dogs[self.ownderdogcount].slug = dogslug
                        self.dogs.append(mydog)
                        self.dogsluglist.append(mydog.slug)
                        self.SaveDogRecord(mydog)
                        ownerdogcount = ownerdogcount + 1
                        var numberofdogrelations = json["dog_relations"].count
                       // self.dogtableview.reloadData()
                      //  print ("Count of related dogs: \(numberofdogrelations)")
                      //  if let weight = json["dog_relations"][2]["dog"]["weight"].int {
                      //      print("dog #3 weight: \(weight)")
                     //   }
                     //   if let name = json["dog_relations"][0]["dog"]["name"].string {
                    //        print("dog #2 name: \(name)")
                       // } //1 dog name
                    } //item status
        } //for loop
       
        //maybe when saving the dogs i'll also update the user record and fill up the dog_relations array with the list of dog slugs
       // print ("Here is my dog slug list: \(self.dogsluglist)")
       // print ("User slug: \(self.userslug)")
        self.dogsluglist = Array(Set(self.dogsluglist))  //remove duplicates by converting to a set and then back to an Array
      //  print ("Here is my updated dog slug list: \(self.dogsluglist)")
        
        let predicate = NSPredicate(format: "slug BEGINSWITH %@", self.userslug)
        let query = CKQuery(recordType: "Owners", predicate: predicate)
        self.publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                print("Error querying records: \(error!.localizedDescription)")
            } else {
                if records!.count > 0 {
                    let record = records!.first! as CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record.setObject(self.dogsluglist as CKRecordValue?, forKey: "dog_relations")
                    // Save this record again
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError)in
                        if saveError != nil {
                            print("Error saving record: \(saveError!.localizedDescription)")
                        } else {
                            print("Successfully updated user record!")
                        }
                    })
                }
            }})
//////////done copy
            
            
        
        } //if let
        }, failure: { error in
            print(error.localizedDescription)
        })
       }  // end of getting the dogs
    
func checkUserExists() {
    //CLOUD retreival
    let reference = CKReference(recordID: self.userrecord, action: .none)
    let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
    let query = CKQuery(recordType: "Owners", predicate: predicate)
    if debug {
        print ("Query: \(query)")
    }
    publicDB.perform(query, inZoneWith: nil) { (records, error) in
        if self.debug {
            print("Record count: \(records?.count)")
            }
        if records?.count == 0 {      //no user account exists, create it then
               // self.loginUser()  // go to fitbark and get token then save it
                
        }
            else   { //the user exists, so grab the token date and make sure it's less than a year old
                // if token date > 1 year, then re-create a token, else token is fine to keep using so we can login
                for owner in records! {
                    if self.debug {
                        print("Dog Owner  firstname: \(owner["first_name"])")
                        print("Dog Owner  token date: \(owner["token_date"])")
                        print("Dog Owner's slug: \(owner["slug"])")
                        self.userslug = String(describing: owner["slug"]!)
                       // }
                    
                     let downloadedimage = owner["image"] as! CKAsset
                        DispatchQueue.main.async {
                            self.userimageview.image = UIImage(
                                contentsOfFile: downloadedimage.fileURL.path
                            )

                        }
                                 }
                    SwiftSpinner.hide()  //we have authenticated

                    self.authtoken = String(describing: owner["token"]!)
                    print ("Token: \(self.authtoken)")
                    let mydate = owner["token_date"] as! Date
                    self.tokendate = mydate
                    if self.debug {
                        print ("Token creation/updated date: \(self.tokendate)")
                    }
                    let currentDateTime = Date()
                   /* need to check for age of token and update if more than a year old
 
                    let timeSince:[Int] = self.timeBetween(self.tokendate, endDate: currentDateTime)
                    if timeSince[0] < 365 {
                        if self.debug {
                            print("The difference between dates is: \(timeSince[0]). No need to get a new token")
                        }
                        else {
                            print ("we need a new token")
                        }
                        
                    }
                     
                     */
                }
 
                
            }
        }
    }

 
}

let DocumentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
let FileManager: FileManager = Foundation.FileManager.default

extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init now web view handler
        let _ = internalWebViewController.webView
        self.navigationItem.title = "Login"

        //watchkit testing
        session?.delegate = self
        session?.activate()

        
               SwiftSpinner.setTitleFont(UIFont(name: "Futura", size: 22.0))
        SwiftSpinner.show("Logging in...", animated: false)
        getusername()  // icloud login
        
                
    }
 
    
    
    // MARK: utility methods
    
    func snapshot() -> Data {
    
            UIGraphicsBeginImageContext(self.view.frame.size)
            self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let fullScreenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(fullScreenshot!, nil, nil, nil)
            return UIImageJPEGRepresentation(fullScreenshot!, 0.5)!
     
    }
    
    
    
    
    override func prepare(for segue: OAuthStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboards.Main.FormSegue {
            
                let controller = segue.destination as? FormViewController
            // Fill the controller
            if let controller = controller {
                controller.delegate = self
            }
        }
        
        super.prepare(for: segue, sender: sender)
    }
    
}

public typealias Queue = DispatchQueue
// MARK: - Table

    extension ViewController: UITableViewDelegate, UITableViewDataSource {
        // MARK: UITableViewDataSource
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")

            cell.textLabel?.text = "FitBark"
            
            return cell
        }
        
        // MARK: UITableViewDelegate
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           
            DispatchQueue.global(qos: .background).async {
                self.doAuthService()
            }
            tableView.deselectRow(at: indexPath, animated:true)
        }
    }
struct FormViewControllerData {
    var key: String
    var secret: String
}

extension ViewController: FormViewControllerDelegate {
    
    var key: String? { return self.currentParameters["consumerKey"] }
    var secret: String? {return self.currentParameters["consumerSecret"] }
    
    func didValidate(key: String?, secret: String?) {
        self.dismissForm()
        print ("Did vaildate")
        self.formData.publish(data: FormViewControllerData(key: key ?? "", secret: secret ?? ""))
    }
    
    func didCancel() {
        self.dismissForm()
        print("Did cancel")
        self.formData.cancel()
    }
    
    func dismissForm() {

             print("form dismissed")
            let _ = self.navigationController?.popViewController(animated: true)
  
    }
}

// Little utility class to wait on data
class Semaphore<T> {
    let segueSemaphore = DispatchSemaphore(value: 0)
    var data: T?
    
    func waitData(timeout: DispatchTime? = nil) -> T? {
        if let timeout = timeout {
            let _ = segueSemaphore.wait(timeout: timeout) // wait user
        } else {
            segueSemaphore.wait()
        }
        return data
    }
    
    func publish(data: T) {
        self.data = data
        segueSemaphore.signal()
    }
    
    func cancel() {
        segueSemaphore.signal()
    }
}

 
    
    
