//
//  PhotoResponse.swift
//  VirtualTourist
//
//  Created by Jerry Hanks on 12/08/2019.
//  Copyright © 2019 Jerry. All rights reserved.
//

import Foundation

struct PhotoMetaData : Codable{
    let id:String
    let owner:String
    let secret:String
    let server:String
    let farm:Int
    let title:String
    let isPublic:Int
    let isFriend:Int
    let isFamily:Int
    
    enum CodingKeys:String, CodingKey{
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
}


struct PhotosForLocation:Codable {
    let page:Int
    let pages:Int
    let perPage:Int
    let total:Int
    let photo:[PhotoMetaData]
    
    enum CodingKeys : String, CodingKey{
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}


struct PhotosForLocationResponse:Codable {
    let photos:PhotosForLocation
    let stat:String
}
