//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Satyanarayana Gopu on 7/14/17.
//  Copyright © 2017 Appfish. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DetailViewController: UIViewController {
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    var coordinate : CLLocationCoordinate2D!
    var images : [ImageData] = []
    var page_no = 1
    var selectedIndexpaths = [IndexPath]()
    var errorOccurred : Bool = false
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    var isSelecting = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.4)
        mapView.setRegion(MKCoordinateRegion(center:coordinate, span : mapSpan), animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.coordinate
        mapView.addAnnotation(annotation)
        startFlickerServices()
    }
    
    
    func startFlickerServices(){
        
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=82174b20665805c27aef79b4a78324e3&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&extras=url_m&per_page=21&page=\(page_no)&format=json&nojsoncallback=1"
        let url = URL(string: urlString)
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            
            if error != nil{
                self.images.removeAll()
                print("error")
            }
            else{
                if let response = response as? HTTPURLResponse, response.statusCode == 200{
                    guard let data = data else{
                        self.presentAlert(message : "No data returned")
                        return
                    }
                    do{
                        guard let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any] else{
                            self.presentAlert(message: "Parse Error")
                            return
                        }
                        guard let photosDict = jsonData["photos"] as? [String : Any] else{
                            return
                        }
                        guard let photoDict = photosDict["photo"] as? [[String : Any]] else{
                            return
                        }
                        for item in photoDict{
                            
                            if let url = item["url_m"] as? String{
                                let url = URL(string: url)
                                let newItem = ImageData(url: url!, data: nil)
                                self.images.append(newItem)
                            }
                            else{
                                continue
                            }
                            
                        }
                        DispatchQueue.main.async {
                            if self.images.isEmpty{
                                self.collectionView.isHidden = true
                                self.errorLabel.isHidden = false
                            }
                            else{
                                self.collectionView.isHidden = false
                                self.errorLabel.isHidden = true
                                self.collectionView.reloadData()
                                for (index, item) in self.images.enumerated(){
                                    
                                    let data = try! Data(contentsOf: item.url)
                                    self.images[index].data = data
                                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                                    
                                    
                                }
                            }
                            
                        }
                        
                     }catch{
                        return
                        
                    }
                }else{
                    self.presentAlert(message: "oops! No data returned. Make sure you have an active internet connection")
                }
            }
        })
        
        task.resume()
        
        
    }
    
    @IBAction func newCollection(_ sender: Any) {
        images.removeAll()
        collectionView.reloadData()
        page_no += 1
        startFlickerServices()
        
    }
    
    
    func presentAlert(message : String){
        
        let alert = UIAlertController(title: "Error Occured", message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    func removeItems(){
        if var selectedIndexes = collectionView.indexPathsForSelectedItems{
            selectedIndexes = selectedIndexes.sorted(by: {
                $0.item > $1.item
            })
            for index in selectedIndexes{
                print("removing item in images array at \(index.item)")
                images.remove(at: index.item)
                print("images array count now is \(images.count)")
            }
            collectionView.deleteItems(at: selectedIndexes)
        }
        
        
    }
    
}

extension DetailViewController : MKMapViewDelegate{
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinAnnotionView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pins")
        return pinAnnotionView
    }
    
    
    
    
}

extension DetailViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        if let data = images[indexPath.item].data{
            let image = UIImage(data: data)
            item.cellImageView.image = image
            item.cellImageView.isHidden = false
            item.acitivityView.stopAnimating()
        }
        else{
            item.cellImageView.isHidden = true
            item.acitivityView.isHidden = false
            item.acitivityView.startAnimating()
        }
        item.contentView.alpha = item.isSelected ? 0.2 : 1
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        print(collectionView.indexPathsForSelectedItems?.count ?? "nil")
        let barbutton = UIBarButtonItem(title: "Remove selected items", style: .plain, target: self, action: #selector(removeItems))
        toolBar.items?[1] = barbutton
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //collectionView.deselectItem(at: indexPath, animated: true)
        if self.collectionView.indexPathsForSelectedItems?.count == 0{
            let barbutton = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(self.newCollection(_:)))
            toolBar.items?[1] = barbutton
        }
        
    }
    
}

extension DetailViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimensions = (self.view.frame.width - 20)
        let dimension = dimensions/3
        return CGSize(width: dimension, height: dimension)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

