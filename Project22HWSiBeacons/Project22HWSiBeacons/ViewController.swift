//
//  ViewController.swift
//  Project22HWSiBeacons
//
//  Created by Mohammed Qureshi on 2020/12/28.
//

//When using CoreLocation you need to ask for permission to get the user's location.
//Need to add access permission Info.plist add Privacy when in usage description and privacy always when in use description.
//Added a label to the main.storyboard and one useful thing is that you can control drag the label to the view itself and then select it to center vertically and horizontally. Then press the reload looking button at the bottom which refreshes the frames and centres the label as required.
//iBeacons have pretty weak signal and range and devices need to be close to the beacon to work.

//problem where the app wouldn't run on device, because device not trusted. To fix on the iPhone, go to general > profile and device management and authorize the app.
import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var distanceReading: UILabel!
    var locationManager: CLLocationManager? //first need to create the object then set a delegate as above CLLocationManagerDelegate. Now need to instantiate it below in viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()//instantiated.
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()// we have to add the privacy location permissions to info.plist for this to actually work.
        //always and when in use
        //if you want to use it only in your own code and when the app is in use we would use .requestWhenInUseAuthorization()
        //this is a non-blocking call which means the code will continue executing and while the user makes their choice about granting access. When decided, we set ourselves as the delegate for our locationManager here. Then calls didChangeAuthorization()
        view.backgroundColor = .gray
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) { //.isMonitoringAvailable = can it detect if a beacon exists?
                if CLLocationManager.isRangingAvailable() { // .isRangingAvailable = can we detect how far a beacon is from our location?
                    startScanning()
                    //dectection and ranging are working if you load the app now but it looks the same. So need to write the code to activate animations when  the ranges are reached from the beacon to  the user.
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        //uuid is an optional, so can use guard let above, but as the uuid is either wrong or right we don't need to do so here.
       // let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon") //Value of optional type 'UUID?' must be unwrapped to a value of type 'UUID' Force Unwrap the uuid String above to solve this.//deprecated in iOS13
        let beaconRegion = CLBeaconRegion(uuid:  uuid, major: 123, minor: 456, identifier: "MyBeacon")
        let beaconRegion1 = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
        locationManager?.startMonitoring(for: beaconRegion)//look for beacons
        //locationManager?.startRangingBeacons(in: beaconRegion) //deprecated in iOS13 tell us how far away we are from the beacons.
        locationManager?.startRangingBeacons(satisfying: beaconRegion1)
        //fixed the deprecated areas with the up to date code.
        
    }

    func update(distance: CLProximity) { //distance is an enum of CLProximity
        //allows cases when multiple beacons emitting same UUID. Pull out the first one to updateDistanceMethod and then change the UI.
        UIView.animate(withDuration: 1) { [unowned self] in
            //solved error with the animations in the param being required to work
        switch distance {
//        case .unknown:
//            self.view.backgroundColor = .gray
//            self.distanceReading.text = "UNKNOWN"
            
        case .far:
            self.view.backgroundColor = .red
            self.distanceReading.text = "FAR"
            
        case .near:
            self.view.backgroundColor = .yellow
            self.distanceReading.text = "CLOSE"
            
        case .immediate:
            self.view.backgroundColor = .green
            self.distanceReading.text = "LOCATION REACHED"
            
        default:
            self.view.backgroundColor = .gray
            self.distanceReading.text = "UNKNOWN"
        }
    }
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        //array of CLBeacons to read inside for the first array and pass to update distance method above.
        //if let beacon = beacons.first {
        if beacons.count > 0 {
            let beacon = beacons[0]
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
    
    
}

