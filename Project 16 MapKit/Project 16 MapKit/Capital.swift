//
//  Capital.swift
//  Project 16 MapKit
//
//  Created by Mohammed Qureshi on 2020/11/09.
//

import UIKit
import MapKit
// can't use structs with MapKit so has to use NSObject to use ObjC code.
class Capital: NSObject, MKAnnotation { // no init so added below. Remember, has to have the same properties as the class itself.
    var title: String?
    var coordinate: CLLocationCoordinate2D //lat and lon associated with location
    var info: String //general info about the city you select.
    var url: String?
    
    init(title: String?, coordinate: CLLocationCoordinate2D, info: String, url: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.url = url
    } // Now we've created the class here we can call it in the VC to access all the data about each city.
    
}
