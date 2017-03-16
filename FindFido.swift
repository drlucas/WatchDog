//
//  FindFido.swift
//  WatchDog
//
//  Created by Ryan Lucas on 2/23/17.
//  Copyright © 2017 Ryan Lucas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CloudKit

class FindFido: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
     @IBOutlet var lastlocationmap: MKMapView!
     @IBOutlet var currentlocationmap: MKMapView!
    
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var horizontalAccuracy: UILabel!
    @IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var verticalAccuracy: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    var savelocation = false
    var dogslug:String!
    
    var thepasseddog:Dog!
    var passedName:String!
    
    var userslug:String! // the string for the user that was passed over from previous controller
    let dogRecord = CKRecord(recordType: "Dogs")
    let publicDB = CKContainer.default().publicCloudDatabase
    var userrecord:CKRecordID!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
        print ("Dog Slug: \(dogslug)")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    // MARK: - Navigation
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        let latestLocation: CLLocation = locations[locations.count - 1]
        
        latitude.text = String(format: "%.4f",
                               latestLocation.coordinate.latitude)
        longitude.text = String(format: "%.4f",
                                latestLocation.coordinate.longitude)
        horizontalAccuracy.text = String(format: "%.4f",
                                         latestLocation.horizontalAccuracy)
        altitude.text = String(format: "%.4f",
                               latestLocation.altitude)
        verticalAccuracy.text = String(format: "%.4f",
                                       latestLocation.verticalAccuracy)
        
        if startLocation == nil {
            startLocation = latestLocation
        }
        
        let distanceBetween: CLLocationDistance =
            latestLocation.distance(from: startLocation)
        
        distance.text = String(format: "%.2f", distanceBetween)
        
        
        let center = CLLocationCoordinate2D(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.lastlocationmap.setRegion(region, animated: true)
         currentlocationmap.showsUserLocation = true
        
        if (self.savelocation == false ){
            self.savelocation = true
            print ("Save location")
            print("Latitude: \(latitude)")
            print("Longitude: \(longitude)")
            if dogslug != nil {
                SaveDogLocation(dogslug, location: latestLocation)
            }
            
        }
    
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate
        userLocation: MKUserLocation) {
        mapView.centerCoordinate = userLocation.location!.coordinate
    }

    
    

    


    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        
    }
    

func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    lastlocationmap.showsUserLocation = (status == .authorizedAlways)
}

 
 
 
 func SaveDogLocation(_ dog2save: String, location:CLLocation ) {
 
 /*
 Matching Records where Record's location is within 100 meters of the given location:
 var location = new CLLocation(37.783,-122.404);
 var predicate = NSPredicate.FromFormat(string.Format("distanceToLocation:fromLocation(Location,{0}) < 100", location));
 */
 
 //get the recordID for the dogslug (which is thepasseddog.slug)
 //then replace the Dog lastlocation record field with the new loaction
 
 let predicate = NSPredicate(format: "slug BEGINSWITH %@", dog2save)
 //print("Dog bday: \(dog2save.birth)")
 let query = CKQuery(recordType: "Dogs", predicate: predicate)
 publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
 if error != nil {
 print("Error querying records: \(error!.localizedDescription)")
 } else {
 if records!.count > 0 {
 let record = records!.first! as CKRecord
 // Now you have grabbed your existing record from iCloud
 // Apply whatever changes you want
 record.setObject(location, forKey: "lastlocation")
 
 // Save this record again
 self.publicDB.save(record, completionHandler: { (savedRecord, saveError)in
 if saveError != nil {
 print("Error saving record: \(saveError!.localizedDescription)")
 } else {
 print("Successfully updated record with new location!")
 }
 })
 }
 }
 })
 
 }
 
 
 
 
 @IBAction func cancelfromCharts(_ segue:UIStoryboardSegue) {
 print ("go back from chart")
 
 }
 
 
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 if segue.identifier == "dogdailychart" {
 print ("Prepare to segue to dog daily chart screen \(thepasseddog.slug)")
 //let destination = segue.destination as! DogDailyChart
 //destination.dogslug = thepasseddog.slug//self.userslug
 //destination.startdate = date1
 //destination.enddate = date2
 }
 }
 
 }

 
 
