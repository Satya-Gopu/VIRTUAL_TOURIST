//
//  File.swift
//  Virtual Tourist
//
//  Created by Satyanarayana Gopu on 7/23/17.
//  Copyright © 2017 Appfish. All rights reserved.
//

import Foundation
import CoreData
import Dispatch

struct CoreDataStack{
    
    private let modelURL : URL!
    private let model : NSManagedObjectModel!
    private let dbURL : URL!
    let managedObjectContext : NSManagedObjectContext!
    private let coordinator : NSPersistentStoreCoordinator!
    
    
    init(modelName : String){
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        self.modelURL = modelURL
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        self.model = mom
        
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        _ = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        //queue.async {
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("Unable to resolve document directory")
        }
        let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
        
        self.dbURL = storeURL
        let options = [NSInferMappingModelAutomaticallyOption : true, NSMigratePersistentStoresAutomaticallyOption : true]
        
        do {
            try self.coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
            //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        //}
        //self.dbURL  = modelURL
    }
    
    func dropAlldata() throws{
        
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
    }
    
    func savecontext() throws{
        if managedObjectContext.hasChanges{
            try managedObjectContext.save()
            
        }
        
    }
    
    func autosave(delay : Int){
        
        if delay > 0{
            do{
                try savecontext()
            }
            catch{
                print("delay less than 0")
            }
            
        }
        
        let nano_time = UInt64(delay) * NSEC_PER_SEC
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: nano_time), execute: {
            self.autosave(delay: delay)
        })
    }
}
