//
//  DogStructure.swift
//  DoggyAI
//
//  Created by ryan on 2016-04-02.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit

struct Dog {
   // var birth = String();
    var birth = Date();
    var gender = String();
    var weight = Int()
    var name = String();
    var slug = String();
    var image = String(); //this is an uuencoded file 
    var owner = String(); // this will be the slug of the dogs's owner
}

struct DailyGoal {
    var goaldate = String();
    var goaltarget = Int()
}

/*
 "id": 13,
 "status": "OWNER",
 "date": "2014-08-19T20:23:52.000Z",
 
 "dog": {
 "slug": "ad7c7166-4cf5-4284-aa56-2cf4df305b31",
 "name": "Barley",
 "bluetooth_id": "c2bc4ee2809939c3",
 "activity_value": 1433,
 "activity_date": "2014-08-30T08:19:50.000Z",
 "birth": "2012-10-30",
 "breed1": {
 "id": 16,
 "name": "BEAGLE"
 },
 "breed2": {
 "id": 15,
 "name": "BASSET HOUND"
 },
 "gender": "M",
 "weight": 41,
 "weight_unit": "lbs",
 "country": "US",
 "zip": "64152",
 "tzoffset": -18000,
 "tzname":"America/Chicago",
 "min_play": 99,
 "min_active": 200,
 "min_rest": 500,
 "medical_conditions": [
 {
 "id": 7,
 "name": "Overweight"
 }
 ],
 "hourly_average": 101,
 "picture_hash": "515d59679a9024ba31e7e9b6103618a5",
 "neutered": false,
 "last_min_time": "2014-08-30T08:19:00.000Z",
 "last_min_activity": 33,
 "daily_goal": 8000,
 "battery_level": 100
 }
 */



struct User {
    var name = String();
    var slug = String();
    var image = String(); //this is an uuencoded file
    var fname = String();
    var lname = String();
    var email = String();
    var pichash = String();
    
    init(name: String, slug: String, image:String, fname:String, lname:String, email:String, pichash:String) {
        self.name = name
        self.slug = slug
        self.image = image
        self.fname = fname
        self.lname = lname
        self.email = email
        self.pichash = pichash
    }
    
}
