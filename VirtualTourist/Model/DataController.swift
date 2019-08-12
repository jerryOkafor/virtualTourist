//
//  DataController.swift
//  VirtualTourist
//
//  Created by Jerry Hanks on 12/08/2019.
//  Copyright © 2019 Jerry. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistenceContainer : NSPersistentContainer
    
    var viewContext : NSManagedObjectContext{
        return persistenceContainer.viewContext
    }
    
    let backgroundContext:NSManagedObjectContext!
    
    
    init(modelName:String) {
        self.persistenceContainer = NSPersistentContainer(name: modelName)
        
        self.backgroundContext = persistenceContainer.newBackgroundContext()
        
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion:(()->Void)?  = nil){
        self.persistenceContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            
            //loaded
            self.configureContexts()
            
            //complete
            completion?()
        }
    }
}
