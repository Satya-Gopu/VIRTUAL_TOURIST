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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    


}

extension DetailViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        item.acitivityView.startAnimating()
        return item
    }
    
    
    
}
