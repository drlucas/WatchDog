//
//  DogParkDetailsViewController.swift
//  WatchDog
//
//  Created by Ryan Lucas on 4/24/17.
//  Copyright © 2017 Ryan Lucas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CloudKit


class park: NSObject {
    var recordID: CKRecordID!
    var name: String!
    var rating: Int!
    var location: CLLocation!
    
    // MARK: - Map Annotation Properties
    var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }
}
 
class DogParkDetailsViewController: UIViewController {

    
    @IBOutlet weak var ParkImage: UIImageView!
    @IBOutlet weak var DogParkName: UILabel!
    @IBOutlet var ParkRatingLabel: UILabel!
    @IBOutlet weak var StarRating1: UILabel!
    @IBOutlet weak var StarRating2: UILabel!
    @IBOutlet weak var StarRating3: UILabel!
    @IBOutlet weak var StarRating4: UILabel!
    @IBOutlet weak var StarRating5: UILabel!

    var parkrating:Int!
    var mypark:Parks!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Display the park name and picture, rating and why not...directions
        StarRating1.isHidden = true
        StarRating2.isHidden = true
        StarRating3.isHidden = true
        StarRating4.isHidden = true
        StarRating5.isHidden = true
        ParkRatingLabel.isHidden = true
        DogParkName.text = mypark.name
        parkrating = mypark.rating
        print("Park rating: \(mypark.rating)")
        print ("Park: \(mypark.recordID)")
        
         self.ParkRatingLabel.isHidden = false
         switch parkrating {
         case 1:
         self.StarRating1.isHidden = false
         self.StarRating2.isHidden = true
         self.StarRating3.isHidden = true
         self.StarRating4.isHidden = true
         self.StarRating5.isHidden = true
         case 2:
         self.StarRating1.isHidden = false
         self.StarRating2.isHidden = false
         self.StarRating3.isHidden = true
         self.StarRating4.isHidden = true
         self.StarRating5.isHidden = true
         case  3:
         self.StarRating1.isHidden = false
         self.StarRating2.isHidden = false
         self.StarRating3.isHidden = false
         self.StarRating4.isHidden = true
         self.StarRating5.isHidden = true
         case 4:
         self.StarRating1.isHidden = false
         self.StarRating2.isHidden = false
         self.StarRating3.isHidden = false
         self.StarRating4.isHidden = false
         self.StarRating5.isHidden = true
         default:
         self.StarRating1.isHidden = false
         self.StarRating2.isHidden = false
         self.StarRating3.isHidden = false
         self.StarRating4.isHidden = false
         self.StarRating5.isHidden = false
         }
 
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
