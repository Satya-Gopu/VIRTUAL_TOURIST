//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Satyanarayana Gopu on 7/14/17.
//  Copyright © 2017 Appfish. All rights reserved.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var image : UIImage!
    @IBOutlet weak var collectionView: UICollectionView!
    var coordinate : CLLocationCoordinate2D!
    var imageURLS : [String] = []
    var errorOccurred : Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        startFlickerServices()
        
    }
    
    func startFlickerServices(){
        
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=82174b20665805c27aef79b4a78324e3&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&extras=url_m&per_page=20&format=json&nojsoncallback=1"
        print(urlString)
        let url = URL(string: urlString)
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            
            if error != nil{
                self.imageURLS.removeAll()
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
                        
                        guard let photoDict = jsonData["photo"] as? [Any] else{
                            return
                        }
                        for item in photoDict{
                            
                            guard let item = item as? [String : Any] else{
                                return
                            }
                            
                            if let url = item["url_m"] as? String{
                                self.imageURLS.append(url)
                            }
                            else{
                                continue
                            }
                            
                        }
                        print(self.imageURLS)
                        
                        
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
    
    func presentAlert(message : String){
        
        let alert = UIAlertController(title: "Error Occured", message: message, preferredStyle: .alert)
        
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { completed in
//            self.navigationController?.popToRootViewController(animated: true)
//        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    


}

extension DetailViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLS.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        item.acitivityView.startAnimating()
        return item
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
