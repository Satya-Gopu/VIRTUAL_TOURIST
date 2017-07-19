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
    var images : [ImageData] = []
    var page_no = 1
    var errorOccurred : Bool = false
    @IBOutlet weak var errorLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        startFlickerServices()
        print("In did load")
    }
    
    
    func startFlickerServices(){
        
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=82174b20665805c27aef79b4a78324e3&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&extras=url_m&per_page=21&page=\(page_no)&format=json&nojsoncallback=1"
        print(urlString)
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
        
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { completed in
//            self.navigationController?.popToRootViewController(animated: true)
//        })
        
        self.present(alert, animated: true, completion: nil)
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
            item.acitivityView.startAnimating()
        }
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
