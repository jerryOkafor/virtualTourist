//
//  ApiClient.swift
//  VirtualTourist
//
//  Created by Jerry Hanks on 12/08/2019.
//  Copyright © 2019 Jerry. All rights reserved.
//

import Foundation
class ApiClient {
    static let apiKey = "0a20f5a7710d283bb0f49830890c73a7"
    static let secrete  = "903b022e256682c9"
    
    enum EndPoints {
        static let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        static let fetchImage = "https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg"
        
        case photos(Double, Double)
        case photosWithPageNumber(Double, Double, Int)
        case imageFromMetadata(Int, String, String, String)
        
        var stringValue: String {
            switch self {
            case .photos(let lat, let lng):
                return EndPoints.base + "&api_key=\(ApiClient.apiKey)" + "&lat=\(lat)&lon=\(lng)&format=json"
            case .photosWithPageNumber(let lat, let lon, let pageNumber):
                return EndPoints.base + "&api_key=\(ApiClient.apiKey)" + "&lat=\(lat)&lon=\(lon)&page=\(pageNumber)&format=json"
            case .imageFromMetadata(let farmId, let serverId, let photoId, let secret):
                return "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(secret).jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getPhotosForLocation(lat:Double, lng:Double) {
        let request = URLRequest(url: EndPoints.photos(lat,lng).url)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error{
                print("Error: \(error)")
            }
            
            guard let data = data else{
                print("Error no Data")
                return
            }
            
            //clean response
            var newDate = data.subdata(in: 14..<data.count)
            newDate.removeLast()
            
            print(String(data:newDate,encoding: .utf8)!)
        }
        
        dataTask.resume()
        
    }
}
