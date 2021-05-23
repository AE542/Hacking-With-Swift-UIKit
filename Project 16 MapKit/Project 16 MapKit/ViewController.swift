//
//  ViewController.swift
//  Project 16 MapKit
//
//  Created by Mohammed Qureshi on 2020/11/09.
//
//first create embed the VC Scene in a navigation controller (remember it gives you the back button and lets you transition between screens)
// when using a mapKit object, the first thing you need to do is drag it to the view and make sure the constraints are to the superview edges for the trailing leading and bottom anchors for it to work like a regular map app.

import UIKit
import MapKit
//import WebKit

//class myPointAnnotation: MKPointAnnotation {
//    var pinTintColor: UIColor!
//
//} could be used for challenge 1 but was not simple.

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView! // cannot find MKMapView error...because we didn't import mapKit.
    //must set MKMapView as a delegate by ctrl dragging from the map view to the VC in the navigation menu, then set the outlet as a delegate. THE APP WON'T WORK if you don't do this.
    
   // var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select Type", style: .plain, target: self, action: #selector(toggleView(_:)))        //isn't crashing with the _ to replace the param name... but isnt;t loading
        
//        let satellite = UIBarButtonItem(barButtonSystemItem: action, target: MKMapType, action: #selector(MKMapType.standard))

        //var webView: WKWebView!
        
//        webView = WKWebView()
//        view = webView
        
        //mapView.delegate = self
        
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home City", url: "https://en.wikipedia.org/wiki/London")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Capital of Norway", url: "https://en.wikipedia.org/wiki/Oslo")
        let tokyo = Capital(title: "Tokyo", coordinate: CLLocationCoordinate2D(latitude: 35.689487, longitude: 139.691711), info: "面白い町だ", url: "https://en.wikipedia.org/wiki/Tokyo")
        let seoul = Capital(title: "Seoul", coordinate: CLLocationCoordinate2D(latitude: 37.566536, longitude: 126.977966), info: "Excellent Street Food", url: "https://en.wikipedia.org/wiki/Seoul")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Amazing Pizza and sights", url: "https://en.wikipedia.org/wiki/Rome")
        let newYork = Capital(title: "New York City", coordinate: CLLocationCoordinate2D(latitude: 40.712776, longitude: -74.005974), info: "Home of The Avengers", url: "https://en.wikipedia.org/wiki/New_York_City")
        
        mapView.addAnnotations([london, oslo, tokyo, seoul, rome, newYork])
        
//        mapView.addAnnotation(oslo)
//        mapView.addAnnotation(tokyo)
//        mapView.addAnnotation(seoul)
//        mapView.addAnnotation(rome)
//        mapView.addAnnotation(newYork)
        //this way is repetitive so better to do it using the above addAnnotations and an array instead for adding annotations.
        //let delegate = mapView.delegate
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil } //so if annotation is not selected it will return nil instead with this guard func.
        //before it was { else } be careful has to return after the opening brace.
        
        let identifier = "Capital" //this will be our reuse identifier to make our annotation views.
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        // will get back one it will dequeue the annotation view
        // solution to challenge 1 needed to typcast the above var into an MKPinAnnotationView.
        
//        var pinTintColor: UIColor! Wasn't the solution to challenge 1
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true //displays extra info in callout bubble
            annotationView?.pinTintColor = .blue
            // solution to challenge 1: Completed, just needed to add the colour here in the if statement to make it work.
            let btn = UIButton(type: .detailDisclosure) // creates the i button with a ring around it
            
            annotationView?.rightCalloutAccessoryView = btn // use this to link to more detailed info from the callout bubble on the right side.
        } else {
            annotationView?.annotation = annotation // if we have an annotationView in a dequeue queue, use it straight away
        }
        return annotationView
            //as? MKPinAnnotationView wasn't the solution needed to typecast the return of dequeueReusableAnnotationView above.
        
        
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return } // guard let and typecast the capital else just bail out if its anything but the Capital.
        
        let placeName = capital.title
        let placeInfo = capital.info
        let urlInfo = capital.url
        
        
        if let url = NSURL(string: urlInfo!) {
            UIApplication.shared.open(url as URL)
        }// this solved challenge 3 and bypassed the ac... not quite what I wanted but close enough...NEEDS RE-DOING
        // when I have time want to present a new VC as a modal vc that can be dismissed.
        //also maybe a UINavigationController so it can go back to the Map.
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        //ac.addAction(UIAlertAction(title: "Website", style: .default, handler: goToWebsite(_:)))
        present(ac, animated: true)
        
        
        
    }
    
//
//    func mapViewURL(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        guard let capital = view.annotation as? Capital else { return }
//        let urlInfo = capital.url
//
//        if let url = NSURL(string: urlInfo!) {
//            UIApplication.shared.open(url as URL)
//        }
//    }
    
//    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//        var standardMap = MKMapType.standard
//        var satelliteMap = MKMapType.satellite
//        
//        
//        
//    }
//
//    @objc func goToWebsite(_ sender: UIAlertAction) {
//
//
//
////
//        if let url = NSURL(string: "https://en.wikipedia.org/wiki/New_York_City") {
//            UIApplication.shared.open(url as URL)
//        }
//
//
//        switch sender.title{
//        case :
//            <#code#>
//        default:
//            <#code#>
//        }
//        } else {
//            print("Unable to open link")

//        }
//        let webView = WKWebView()
//        guard let senderTitle = sender.title else { return }
//        guard let url = URL(string: "https://en.wikipedia.org/wiki/London") else { return }
//        webView.load(URLRequest(url: url)) // caused error and didn't load the website.



//        switch sender {
//        case london:
//
//        default:
//            <#code#>
//        }
//    }
    
    
    
    @objc func toggleView(_ sender: UIAlertAction) {

    
        
        //var standardMap= MKMapType.standard
        if sender.title == "Standard" {
            self.mapView.mapType = MKMapType.standard
        } else if sender.title == "Satellite" {
            self.mapView.mapType = MKMapType.satellite
        }
        
        //isn't crashing anymore but still not changing.
        //OK!!! SOLVED IT!! sender should have been a UIAlertAction! Also the handler should have been set to toggleView with no internal param name. the sender being a UIAlertAction here means that its title is of course the name of the UIAlertAction.
//
//        var satelliteMap = MKMapType.satellite
        
//        switch sender {
//        case "Standard"
//            self.mapView.mapType = MKMapType.standard
//        case "Satellite":
//            self.mapView.mapType = MKMapType.satellite
//        default:
//            self.mapView.mapType = MKMapType.satellite
//            break
//        }
//        var standardMap = MKMapType.standard
//
//        var satelliteMap = MKMapType.satellite
        //guard let actionTitle = action.title else  { return }
        
//        if actionTitle == "Standard" {
//
//        } else if actionTitle == "Satellite" {
//
//
//        }

//        func toggleViewSatellite(sender: UIBarButtonItem) {
//            mapView.mapType = MKMapType.satellite
//        }
//
        //mapView.mapType = MKMapType.standard {mapView.mapType == MKMapType.satellite}
        
        let ac = UIAlertController(title: "Choose Type", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: toggleView(_:)))
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: toggleView(_:)))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    

}
//for challenge: Maps have a mapType property that lets us control the satellite or map being viewable.
