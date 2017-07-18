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
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager : CLLocationManager!
    var gesture : UILongPressGestureRecognizer!
    var edit = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined{
            
            locationManager.requestAlwaysAuthorization()
            
        }
        locationManager.requestLocation()
        mapView.showsUserLocation = true
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(gestured))
        mapView.addGestureRecognizer(gesture)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.delegate = self
    }
    
    func gestured(sender : UILongPressGestureRecognizer){
        
        if sender.state == .ended{
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let annoatation = MKPointAnnotation()
            annoatation.coordinate = coordinate
            mapView.addAnnotation(annoatation)
            print(mapView.annotations.count)
        }
    }
    @IBAction func editFunction(_ sender: Any) {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneFunction))
        mapView.frame.origin.y = mapView.frame.origin.y - editLabel.frame.height
        editLabel.frame.origin.y = editLabel.frame.origin.y - editLabel.frame.height
        edit = true
    }
    
    func doneFunction(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editFunction(_:)))
        mapView.frame.origin.y = mapView.frame.origin.y + editLabel.frame.height
        editLabel.frame.origin.y = editLabel.frame.origin.y + editLabel.frame.height
        edit = false
        
    }
    
    
}

extension ViewController : CLLocationManagerDelegate{
    
    
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
        if annotation is MKUserLocation{
            return nil
        }
        else{
            let pinAnnotionView : MKPinAnnotationView!
            if let dequeuedPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView{
                
                pinAnnotionView = dequeuedPinView
                
            }
            else{
                
                pinAnnotionView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                
            }
            return pinAnnotionView
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if edit{
            mapView.removeAnnotation(view.annotation!)
        }
        else{
            mapView.deselectAnnotation(view.annotation, animated: true)
            if let coordinate = view.annotation?.coordinate{
                
                print("latitude is \(coordinate.latitude) and longitude is \(coordinate.longitude)")
                
                let camera = MKMapCamera(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 50)
                camera.pitch = 0
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                let snapoptions = MKMapSnapshotOptions()
                snapoptions.camera = camera
                snapoptions.region = region
                let snapshotter = MKMapSnapshotter(options: snapoptions)
                snapshotter.start(completionHandler: {(snapshot, error) in
                    if error == nil{
                        let detail = self.storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailViewController
                        detail.image = snapshot?.image
                        detail.coordinate = coordinate
                        self.navigationController?.pushViewController(detail, animated: true)
                        
                        
                    }
                    
                })
            } 
        }
        
    }
    
    
    
}

