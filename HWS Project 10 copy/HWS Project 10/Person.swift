//
//  Person.swift
//  HWS Project 10
//
//  Created by Mohammed Qureshi on 2020/09/09.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit

class Person: NSObject, Codable {//only need to add Codable to allow saving function using JSON, don't need to create required init below or aCoder and aDecoder below.
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
//    required init?(coder aDecoder: NSCoder) {// use of unresolved identifier aDecoder, because parens has no name for it.
//        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
//        image = aDecoder.decodeObject(forKey: "image") as? String ?? ""//needed space between String and ?? to work
//        //here reading code from disk
//
//    }//needed to close required init? method here so it would conform to the protocol
//        func encode(with aCoder: NSCoder) {
//            aCoder.encode(name, forKey: "name")
//            aCoder.encode(image, forKey: "image")
//            //with these changes the Person class now conforms to NSCoding.
//            //reading to the disk.
//        }
    }


