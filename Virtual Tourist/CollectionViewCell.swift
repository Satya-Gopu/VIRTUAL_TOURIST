//
//  CollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Satyanarayana Gopu on 7/14/17.
//  Copyright © 2017 Appfish. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    @IBOutlet weak var acitivityView: UIActivityIndicatorView!
    
    override var isSelected: Bool{
        willSet{
            if newValue{
                self.contentView.alpha = 0.2
            }
            else{
                
                self.contentView.alpha = 1
            }
            
            
            
        }
        
        
        
        
        
    }
    
    
    
}
