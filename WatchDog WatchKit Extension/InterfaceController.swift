//
//  InterfaceController.swift
//  WatchDog WatchKit Extension
//
//  Created by Ryan Lucas on 12/31/16.
//  Copyright © 2016 Ryan Lucas. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CloudKit




class InterfaceController: WKInterfaceController,  WCSessionDelegate {
    //lets try to get cloudkit data into the app 
    
   // let publicDB = CKContainer(identifier: "iCloud.aussies.ca.Watchdog") //CKContainer.default().publicCloudDatabase
    let publicDB = CKContainer.default().publicCloudDatabase
   // containerIdentifier=iCloud.aussies.ca.WatchDog
    /*
 So you have to make sure that instead of CKContainer.defaultContainer() you use: CKContainer(identifier: "iCloud.com.Moodler.Moodler")
 */
    var userrecord:CKRecordID!
    let OwnerRecord = CKRecord(recordType: "Owners")
    var credentials:String!
    let debug = true   // used to print debug info to the All output screen
    var authtoken = "" as String! // my authentication token to use in fitbark
    var firstname = "" as String!
    var lastname = "" as String!
    var tokendate:Date! //date when token was originally created
    
    //start up a session to commincate with iphone
    let session = WCSession.default()
    
    @IBAction func fetchpoints() {
       print("get  fitbark points")
        //Send Data to iOS
        let msg = ["StringValueSentFromiWatch" : "Hello World"]
        session.sendMessage(msg, replyHandler: { (replay) -> Void in
            print("apple watch sent")
        }) { (error) -> Void in
            print("apple watch sent error")
        }
    // now go get cloudkit stuff for fun
        print ("Cloudy watch")
        gogetcloud()
    }
    
    
    func gogetcloud () {
       // let container = CKContainer.default()
         let container = CKContainer.init(identifier: "iCloud.aussies.ca.WatchDog")
      //  let container = CKContainer.init(identifier: "containerIdentifier=iCloud.aussies.ca.WatchDog")
/* Error: Optional(<CKError 0x17d38520: "Server Rejected Request" (15/2000); server message = "Internal server error"; uuid = 656C1EA8-A74E-4A4D-BACD-AE9B3AD9CFAE; container ID = "iCloud.aussies.ca.WatchDog.watchkitapp.watchkitextension">)
*/
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
                        //self.checkUserExists()
                    })
                }
                
                
            }
        }
        

    }
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?){
    }
    
    func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
        
        guard let image = UIImage(data: messageData as Data) else {
            return
        }
    }
    
    
    
    // Receiver file function
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // handle receiving file
        DispatchQueue.main.async {
            let imageData = NSData.init(contentsOf: file.fileURL)
            print ("Image: \(imageData)")
            let image = UIImage(data: imageData as! Data)
            print ("Update woof picture")
            self.dogimageview.setImage(image)
        
        }
    }
      
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: ([String : Any]) -> Void) {
        print("Message - received")
        let msg = message["StringValueSentFromiWatch"] as! String
        //Send reply
        let data = ["receivedData" : true]
        replyHandler(data as [String : AnyObject])
        DispatchQueue.main.async {
           self.dogbarkpoints.setText(msg)
        self.gogetcloud()
        }
    }
   
    @IBOutlet var dogimageview: WKInterfaceImage!
    //@IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var dogbarkpoints: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        session.delegate = self
        session.activate()
      
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

   

}
