//
//  MonthlyActivityViewController.swift
//  WatchDog
//
//  Created by Ryan Lucas on 3/23/17.
//  Copyright © 2017 Ryan Lucas. All rights reserved.
//

import UIKit

class MonthlyActivityViewController: UIViewController {

    
    var dogslug:String! // the slug for the dog

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print ("lets show the daily average for the current month for \(dogslug)")
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

}
