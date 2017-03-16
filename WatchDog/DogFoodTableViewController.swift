//
//  DogFoodTableViewController.swift
//  WatchDog
//
//  Created by Ryan Lucas on 2/27/17.
//  Copyright © 2017 Ryan Lucas. All rights reserved.
//

import UIKit

class DogFoodTableViewController: UITableViewController, UISearchResultsUpdating {
    
    
    var Foods = ["Purina", "Acana", "Kirkland"]
    var filterFoods = [String]()
    var foodtopass = ""
    var searchController : UISearchController!
    var resultsController = UITableViewController()
    
    
    @IBAction func unwindFromFood(segue: UIStoryboardSegue) {
        print ("I'm back from FOOD")
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        //self.searchController.searchBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Dog foods \(Foods.count)")
        
        self.resultsController.tableView.dataSource = self
        self.resultsController.tableView.delegate = self
        
        self.searchController = UISearchController(searchResultsController: self.resultsController)
        self.searchController.searchResultsUpdater = self

        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "foodcell")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //
        
        self.filterFoods = self.Foods.filter ({ (Food:String) -> Bool in
            if Food.lowercased().contains(self.searchController.searchBar.text!.lowercased()) {
                print ("Filtered Food: \(Food)")
                return true
            }
            else {
                print ("Not filtered")
                return false
            }
        })
        //update table results 
        self.resultsController.tableView.reloadData()
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print ("count: \(self.Foods.count)")
        if tableView == self.tableView {
             return self.Foods.count
        } else {
        return self.filterFoods.count
        }
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       //   let cell = tableView.dequeueReusableCell(withIdentifier: "foodcell", for: indexPath)
        let cell =  UITableViewCell()
        if tableView == self.tableView {
            cell.textLabel?.text = Foods[indexPath.row]
        } else {
            cell.textLabel?.text = filterFoods[indexPath.row]
        }
        // Configure the cell...
        print ("Food: \(self.Foods[indexPath.row])")
        return cell
    }
    
    //didSelectRowAtIndexPath
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if tableView == self.tableView {
            print("Food Selected:  \(Foods[indexPath.row]) ")
            self.foodtopass = Foods[indexPath.row]
         } else {
            print("Food Selected:  \(filterFoods[indexPath.row]) ")
            self.foodtopass = filterFoods[indexPath.row]
        }
        performSegue(withIdentifier: "foodie", sender: self)
    }

    /*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("detailSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let listVC = segue.destinationViewController as! FriendDetailViewController
    }
    
 */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "foodie" {
            print ("it is prepareing")
            self.searchController.isActive = false
            //self.searchController.searchBar.isHidden = true
            // self.searchBar.hidden = true
            let fooddetailVC = segue.destination as! DogFoodDetails
            fooddetailVC.brand = self.foodtopass
        }
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
}
