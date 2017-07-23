//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Satyanarayana Gopu on 7/12/17.
//  Copyright © 2017 Appfish. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController{
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager : CLLocationManager!
    var gesture : UILongPressGestureRecognizer!
    var edit = false
    lazy var pinArray = [Pin]()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mapView.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined{
            
            locationManager.requestAlwaysAuthorization()
            
        }
        locationManager.requestLocation()
        mapView.showsUserLocation = true
        let context = appDelegate!.coreDataStack.managedObjectContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        pinArray = try! context?.fetch(fetch) as! [Pin]
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(gestured))
        mapView.addGestureRecognizer(gesture)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for pin in pinArray{
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            mapView.addAnnotation(annotation)
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func gestured(sender : UILongPressGestureRecognizer){
        
        if sender.state == .ended{
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let annoatation = MKPointAnnotation()
            annoatation.coordinate = coordinate
            mapView.addAnnotation(annoatation)
            let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: appDelegate!.coreDataStack.managedObjectContext)
            let newPin = NSManagedObject(entity: entityDescription!, insertInto: appDelegate!.coreDataStack.managedObjectContext) as! Pin
            newPin.latitude = coordinate.latitude
            newPin.longitude = coordinate.longitude
            try! appDelegate?.coreDataStack.savecontext()
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
                let detail = self.storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailViewController
                detail.coordinate = coordinate
                self.navigationController?.pushViewController(detail, animated: true)
                
            } 
        }
        
    }
    
    
    
}

