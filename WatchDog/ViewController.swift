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

class ViewController: OAuthViewController {
  
    //
    //
    
    //test
    
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

    @IBAction func saveuserbutton(_ sender: Any) {
        SaveOwnerRecord() 
    }
   
    let oauthswift = OAuth2Swift(
        consumerKey:    "fdcb4ac3295906a977f6317979ffaab6d11d93e833c1f41ed834c2b0908cdf2c",
        consumerSecret: "4ca58af6e0b5c9188d17fc92366c86b8f1f4c8bd9e77ef847edc6479487ef120",
        authorizeUrl:   "https://app.fitbark.com/oauth/authorize",
        accessTokenUrl: "https://app.fitbark.com/oauth/token",
        responseType:   "code"
    )
  //  var oauthswift: OAuthSwift?
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
    
func getuserslug() {
    
    /*
 
 let _ = oauthswift.client.get("https://app.fitbark.com/api/v2/user", parameters: [:], success: { response in
 let jsonDict = try? response.jsonObject()
 print(jsonDict as Any)
 },
 failure: { error in
 print(error.description)
 }
 )
 }
     
     oauthswift.client.get("http://api.linkedin.com/v1/people/~?", parameters: parameters, success: { (data, response) -> Void in
     println("Succes") // or print some data from the profile
     }, failure: { (error) -> Void in
     println("Failed") // or reason what failed
     })
 */
    print ("getuserslug")
    let _ = oauthswift.client.get("https://app.fitbark.com/api/v2/user", parameters: [:], success: { response in
        let jsonDict = try? response.jsonObject() as AnyObject!
      //  print(jsonDict as AnyObject!)
        let curr_user = jsonDict?["user"] as! NSDictionary?
        let slug = curr_user!["slug"] as? String
        self.firstname = curr_user!["first_name"] as? String
        self.lastname = curr_user!["last_name"] as? String
        self.userslug = slug!
        print ("Slug: \(self.userslug)")
      //  print("jsonDict: \(jsonDict)")
        
    },
                                  failure: { error in
                                    print(error.description)
    }
    )


                         //   let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
    
                            
    
    
        print ("gotuserslug")
        
    }

    
    func SaveOwnerRecord() {
        /*SAVE*/
        //     self.keychain["the_token_key"] = self.oauthswift.client.credential.oauth_token
  //      authtoken = self.oauthswift.client.credential.oauth_token
        OwnerRecord["first_name"] = self.firstname as CKRecordValue?
        OwnerRecord["last_name"] = self.lastname as CKRecordValue?
        //OwnerRecord["token"] = self.oauthswift.client.credential.oauth_token
        OwnerRecord["token"] = self.authtoken as CKRecordValue?
        OwnerRecord["token_date"] = Date() as CKRecordValue?
        OwnerRecord["slug"] = self.userslug as CKRecordValue?
        publicDB.save(OwnerRecord, completionHandler: { [unowned self] (record, error) -> Void in
            DispatchQueue.main.async {
                if error == nil {
                    self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                    print("TOken: \(self.authtoken)")
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
   // self.oauthswift = oauthswift
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
    
    //now get the access code and go  get a token
  //  self.testFitBark(oauthswift)
    
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
                     //   SwiftSpinner.hide()  //we have authenticated
                    }
                    
                    //  let downloadedimage = user["image"] as! CKAsset
                    //  self.userImageView.image = UIImage(
                    //      contentsOfFile: downloadedimage.fileURL.path!
                    //  )
    
                    self.authtoken = String(describing: owner["token"]!)
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

 
    
    
