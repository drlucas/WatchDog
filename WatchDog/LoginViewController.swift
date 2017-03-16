//
//  LoginViewController.swift
//  WatchDog
//
//  Created by Ryan Lucas on 2/27/17.
//  Copyright © 2017 Ryan Lucas. All rights reserved.
//
// https://github.com/p2/OAuth2/wiki/Alamofire-4 use this class to login the user to fitbark
import UIKit
import Foundation
import OAuth2
import Alamofire

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBAction func login(_ sender: Any) {
        if((username.text != "") && (password.text  != "")){
            print ("something entereted")
        }
        else {print ("nothing entereed")}
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
