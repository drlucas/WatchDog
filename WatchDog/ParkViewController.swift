//
//  ParkViewController.swift
//  WatchDog
//
//  Created by Ryan Lucas on 3/28/17.
//  Copyright © 2017 Ryan Lucas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CloudKit

class Parks: NSObject, MKAnnotation {
    var recordID: CKRecordID!
    var name: String!
    var rating: Int!
    var location: CLLocation!
    
    // MARK: - Map Annotation Properties
    var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }

    //init(name: String, rating: Int, location: CLLocation) {
        init(recordID: CKRecordID, name: String, rating: Int, location: CLLocation) {
        self.recordID = recordID
        self.name = name
        self.rating = rating
        self.location = location
    }
}

extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}
class ParkPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var rating: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.name = title
        self.rating = subtitle
    }
}



class ParkViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate,  UITableViewDataSource, MKMapViewDelegate  {
    

    @IBOutlet weak var ParkTableView: UITableView!
    @IBOutlet weak var ParkMapView: MKMapView!
    @IBOutlet weak var UserLocationLabel: UILabel!
    var locationManager: CLLocationManager = CLLocationManager()
    var myLocation: CLLocation!
    var userslug:String! // the string for the user that was passed over from previous controller - needed??
    let ParkRecord = CKRecord(recordType: "Parks")
    let publicDB = CKContainer.default().publicCloudDatabase
    var userrecord:CKRecordID!
    var latitude:String!
    var longitude:String!
    var parks = [Parks]()
   // var isDirty:Bool!
    var parkrating = 0
    var parktopass = -1
    
    //https://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
    let regionRadius: CLLocationDistance = 1000
    
    //A “dirty” flag tracks when the derived data is out of sync with the primary data.
    //It is set when the primary data changes. If the flag is set when the derived data
    //is needed, then it is reprocessed and the flag is cleared. Otherwise,
    //the previous cached derived data is used.
    
    
    //viewWillAppear() is going to clear the table view's selection if it has one,
    //then it will use the isDirty flag to call loadTeachers() if it's needed.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = ParkTableView.indexPathForSelectedRow {
            ParkTableView.deselectRow(at: indexPath, animated: true)
        }
        
   //     if isDirty {
           // GetParks()
   //         print("get parks")
   //     }
    }
    
    @IBAction func unwindFromPark2(segue: UIStoryboardSegue) {
        print ("I'm back from park details")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
   //     let chicagoCoordinate = CLLocationCoordinate2DMake(41.8832301, -87.6278121)// 0,0 Chicago street coordinates
          // class ChicagoCenterCoordinate: NSObject,MKAnnotation{   // https://makeapppie.com/tag/mkannotationview/
          //  var coordinate: CLLocationCoordinate2D = chicagoCoordinate
          //  var title: String? = "0,0 Street Numbers"
      //  }
        
        
    //    ParkMapView.addAnnotation(parks)

    
     //   ParkMapView.addAnnotation(ChicagoCenterCoordinate())
        
        
        // Do any additional setup after loading the view.
     //   isDirty = true
        // Get the users current address
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        // locationManager.startUpdatingLocation()
     //   resetRegion()
        // Query the Park Database for the 3 nearest parks
        // GetParks()
        /*
 https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/CloudKitQuickStart/AddingAssetsandLocations/AddingAssetsandLocations.html
         NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %f","Location",location,radiusInKilometers)
         queryOperation.sortDescriptors = [CKLocationSortDescriptor(key: "location", relativeLocation: location)]
         queryOperation.resultsLimit = 5
 */
      
       // tableView.delegate = self
      //  tableView.dataSource = self
    //
        }
 
    
    func tableView(_  tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ParkTableView.dequeueReusableCell(withIdentifier: "ParkLabelCell", for: indexPath)
        cell.textLabel?.text = "\(self.parks[indexPath.row].name!)"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      //  return sectionedRecords.sections.count
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          print ("count: \(parks.count)")
         return parks.count
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Closest Dog Parks"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("Park Selected:  \(self.parks[indexPath.row].name!) ")
        
          self.parktopass = indexPath.row
       // self.parkrating = self.parks[indexPath.row].rating!
        //  self.parktopass = self.parks[indexPath.row].name!
        performSegue(withIdentifier: "parkie", sender: self)
        
        
    }
 
  override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "parkie"  {
            print ("it is prepareing")
            let parkdetailVC = segue.destination as! DogParkDetailsViewController
            parkdetailVC.mypark = self.parks[parktopass]
           // parkdetailVC.parkrating = self.parkrating
    }
}
    


    func GetParks() {
        let pred = NSPredicate(value: true)
        let query = CKQuery(recordType: "Parks", predicate: pred)
        //query.sortDescriptors = [CKLocationSortDescriptor(key: "Location", relativeLocation: myLocation)]
        //let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        let sort = CKLocationSortDescriptor(key: "Location", relativeLocation: myLocation)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        //Set the desiredKeys property to be an array of the record keys you want
       
    
        
        operation.desiredKeys = ["Name", "OverallRating", "Location"]
        operation.resultsLimit = 3
        
        //CKQueryOperation has two closures. One streams records and one is
        //called when the records have been downloaded. To handle this you
        //can create a new array that will hold the parks as they are parsed.
        var newParks = [Parks]()
        
        //Set a recordFetchedBlock closure on the CKQueryOperation object.
        //This will be given a CKRecord value for every record that gets
        //downloaded, and the convert that into a Parks object.
        operation.recordFetchedBlock = { record in
           // let park = Parks(name: record["Name"] as! String, rating:record["OverallRating"] as! Int, location:record["Location"] as! CLLocation)
            let park = Parks(recordID: record.recordID as! CKRecordID, name: record["Name"] as! String, rating:record["OverallRating"] as! Int, location:record["Location"] as! CLLocation)
            park.recordID = record.recordID
            print ("Park record: \(park.recordID)")
            park.name = record["Name"] as! String
            park.rating = record["OverallRating"] as! Int
            park.location = record["Location"] as! CLLocation
         
           // let location = record["Location"] as! CLLocation
         //   let long = location.coordinate.latitude;
        //    let lat = location.coordinate.longitude;
      //      park.coordinate = CLLocationCoordinate2DMake(lat, long)// 0,0 Chicago street coordinate
            
            newParks.append(park)
            
            self.ParkMapView.addAnnotation(park)
            print ("Park name: \(park.name)")
            print ("Park Location: \(park.location)")
            
            //print("my location: \(userLocation)")
            //let coord = closestLocation(locations: coordinates, closestToLocation: userLocation!)
            // Returned value is in meters
            let distanceMeters = self.myLocation?.distance(from: park.location!)
            print ("Distance = \(distanceMeters)")
        }
        
        //Called by CloudKit when all records have been downloaded, and will be
        //given two parameters: a query cursor and an error if there was one.
        //The query cursor is useful if you want to implement paging.
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.parks = newParks
                    print ("done")
                    
            /* ---- ------
                    print("Closest park name is \(newParks[0].name!)")
                    self.ClosestPark.text = (newParks[0].name!)
                   
    */
                    
                    
                    self.ParkTableView.reloadData()
                } else {
                    let ac = UIAlertController(title: "Fetch failed", message: "Please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
        
        //Ask CloudKit to run it
        CKContainer.default().publicCloudDatabase.add(operation)
       // print (newParks)
       // print (operation)
        
    } //End of loadparks()

    
    
    @IBAction func FindParks(_ sender: Any) {
        //https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
        print("Where am i?")
        latitude = String(format: "%.4f", myLocation.coordinate.latitude)
        longitude  = String(format: "%.4f", myLocation.coordinate.longitude)
        print("Latitude: \(latitude)")
        print("Longitude: \(longitude)")
        //locationManager.stopUpdatingLocation()
        //let latestLocation: CLLocation = locations[locations.count - 1]
        //print ("Count: \(locations.count)")
        let coord1 = CLLocation(latitude: 52.45678, longitude: 13.98765)
        let coord2 = CLLocation(latitude: 52.12345, longitude: 13.54321)
        let coord3 = CLLocation(latitude: 48.771896, longitude: 2.270748000000026)
        //http://stackoverflow.com/questions/38960997/how-to-calculate-the-distance-between-my-current-location-and-other-pins-in-mapv
        // var userLocation:CLLocation = locations[0]
        let long = myLocation.coordinate.latitude;
        let lat = myLocation.coordinate.longitude;
        let coordinates = [ coord1, coord2, coord3]
        let userLocation = myLocation
        print("my location: \(userLocation)")
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userLocation!, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? String {
                print(city)
                self.UserLocationLabel.text = city as? String
            }
            else {
                self.UserLocationLabel.text = "Unknown"
                
            }
           
        
            
        })

        let coord = closestLocation(locations: coordinates, closestToLocation: userLocation!)
        // Returned value is in meters
        let distanceMeters = userLocation?.distance(from: coord!)
        // If you want to round it to kilometers
        let distanceKilometers = distanceMeters! / 1000.00
        // Display it in kilometers
        let roundedDistanceKilometers = String(Double(round(100 * distanceKilometers) / 100)) + " km"
        print("my location distance: \(roundedDistanceKilometers)")
        GetParks()
        
        

        // show parks on map
       // let mypark = parks[0]
        
 
        
    }
    
    func resetRegion(){
        let long = myLocation.coordinate.latitude;
        let lat = myLocation.coordinate.longitude;
        let myCoordinate = CLLocationCoordinate2DMake(lat, long)// 0,0 Chicago street coordinate
        let myregion = MKCoordinateRegionMakeWithDistance(myCoordinate, 9000, 9000)
        ParkMapView.setRegion(myregion, animated: true)
        centerMapOnLocation(location: myLocation!)
        //ParkMapView.addAnnotation(mycoord as! MKAnnotation)
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"
        
      //  if annotation.isKind(of: MKUserLocation()) {
//            return nil
//        }
        
        var annotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            let label1 = UILabel(frame: CGRect(0, 0, 200, 21))
            label1.text = "Some text1 some text2 some text2 some text2 some text2 some text2 some text2"
            label1.numberOfLines = 0
            annotationView!.detailCalloutAccessoryView = label1;
            
            let width = NSLayoutConstraint(item: label1, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 200)
            label1.addConstraint(width)
            
            let height = NSLayoutConstraint(item: label1, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 90)
            label1.addConstraint(height)
            
            
            
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        ParkMapView.setRegion(coordinateRegion, animated: true)
    }

    
    func closestLocation(locations: [CLLocation], closestToLocation location: CLLocation) -> CLLocation? {
        if let closestLocation = locations.min(by: { location.distance(from: $0) < location.distance(from: $1) }) {
            print("closest location: \(closestLocation), distance: \(location.distance(from: closestLocation))")
            return closestLocation
        } else {
            print("coordinates is empty")
            return nil
        }
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.first {
            print("my location: \(location)")
            myLocation = location
            resetRegion()
        }
         myLocation = locations.first
        
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



/* 
 
 stuff brought over from FindFido 
 
 
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
 
 
 

 
 
 
 --------want to create a function that takes as parameters:
 
 An array filled of coordinates
 The current user location
 And return the closest location between the user's location and the array locations.
 
 Here are my locations:
 
 let coord1 = CLLocation(latitude: 52.45678, longitude: 13.98765)
 let coord2 = CLLocation(latitude: 52.12345, longitude: 13.54321)
 let coord3 = CLLocation(latitude: 48.771896, longitude: 2.270748000000026)
 User location function:
 
 func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 var userLocation:CLLocation = locations[0]
 let long = userLocation.coordinate.longitude;
 let lat = userLocation.coordinate.latitude;
 
 let coordinates = [ coord1, coord2, coord3]
 
 userLocation = CLLocation(latitude: lat, longitude: long)
 
 print("my location: \(userLocation)")
 closestLocation(locations: coordinates, closestToLocation: userLocation)
 }
 Coordinates comparison function
 
 
 Result when I print closestLocation and distanceKM:
 
 closest location: <+48.77189600,+2.27074800> +/- 0.00m (speed -1.00 mps / course -1.00) @ 14/01/2017 00:16:04 heure normale d’Europe centrale, distance: 5409.0
 As you can see, the distance (in km) is very huge while these locations are the same cit
 
 func closestLocation(locations: [CLLocation], closestToLocation location: CLLocation) -> CLLocation? {
 if let closestLocation = locations.min(by: { location.distance(from: $0) < location.distance(from: $1) }) {
 print("closest location: \(closestLocation), distance: \(location.distance(from: closestLocation))")
 return closestLocation
 } else {
 print("coordinates is empty")
 return nil
 }
 }
 
 // We know the answer is coord3 and the distance is 0
 closestLocation(locations: [coord1, coord2, coord3], closestToLocation: coord3)
 */
