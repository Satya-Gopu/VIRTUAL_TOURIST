//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Satyanarayana Gopu on 7/12/17.
//  Copyright © 2017 Appfish. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager : CLLocationManager!
    var gesture : UILongPressGestureRecognizer!
    override func viewWillLayoutSubviews() {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(gestured))
        mapView.addGestureRecognizer(gesture)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined{
            
            locationManager.requestAlwaysAuthorization()
            
        }
        locationManager.requestLocation()
    }
    
    func gestured(){
        
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        let annoatation = MKPointAnnotation()
        annoatation.coordinate = coordinate
        mapView.addAnnotation(annoatation)
    }

   
}

extension ViewController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        mapView.setCenter((locations.last?.coordinate)!, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        locationManager.stopUpdatingLocation()
    }
    
}

extension ViewController : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinAnnotionView : MKPinAnnotationView!
        
        if let newPin = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView{
            
            pinAnnotionView = newPin
            
        }
        else{
            
            pinAnnotionView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            
        }
        pinAnnotionView.animatesDrop = true
        return pinAnnotionView
        
    }
    
    
    
}

