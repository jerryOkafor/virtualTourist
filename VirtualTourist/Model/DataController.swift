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
    
    
    init(modelName:String) {
        self.persistenceContainer = NSPersistentContainer(name: modelName)
        
    }
    
    func load(completion:(()->Void)?  = nil){
        self.persistenceContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            
            //loaded
            //configurecontexts
            //configure auto save contexts
            
            //complete
            completion?()
        }
    }
}
