//
//  Image+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Satyanarayana Gopu on 7/23/17.
//  Copyright © 2017 Appfish. All rights reserved.
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var pin: Pin?

}
