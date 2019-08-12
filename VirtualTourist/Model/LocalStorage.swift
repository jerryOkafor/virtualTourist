//
//  LocalStorage.swift
//  VirtualTourist
//
//  Created by Jerry Hanks on 12/08/2019.
//  Copyright © 2019 Jerry. All rights reserved.
//

import Foundation

class LocalStorage {
    private static let userDefault = UserDefaults(suiteName: "virtual_tourist")!
    
    static var mapData:MapData?{
        get { if let mapData = userDefault.object(forKey: keyMapData) as? Data{
            return try? PropertyListDecoder().decode(MapData.self, from: mapData)
        }else{return nil}
            
        }
        set(value){userDefault.set(try? PropertyListEncoder().encode(value),forKey: keyMapData)}
    }
    
    
    static func clear(){
        let dictionary = userDefault.dictionaryRepresentation()
        dictionary.keys.forEach { key in userDefault.removeObject(forKey: key)}
        
        print(Array(userDefault.dictionaryRepresentation().keys).count)
    }
    
    
    private static let keyMapData = "vt+map_data"

}
