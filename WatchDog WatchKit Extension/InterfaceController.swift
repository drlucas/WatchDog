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


class InterfaceController: WKInterfaceController,  WCSessionDelegate {
    
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
    
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?){
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: ([String : Any]) -> Void) {
        print("Message - received")
        let msg = message["StringValueSentFromiWatch"] as! String
        //Send reply
        let data = ["receivedData" : true]
        replyHandler(data as [String : AnyObject])
        DispatchQueue.main.async {
            self.dogbarkpoints.setText(msg)
            
        }
        
    }
   
    @IBOutlet var dogimageview: WKInterfaceImage!
    
    
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
