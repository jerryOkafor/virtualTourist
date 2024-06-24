//
//  ApiClient.swift
//  VirtualTourist
//
//  Created by Jerry Hanks on 12/08/2019.
//  Copyright © 2019 Jerry. All rights reserved.
//

import Foundation
class ApiClient {
    enum EndPoints {
        static let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        static let fetchImage = "https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg"
        
        case photos(Double, Double)
        case photosWithPageNumber(Double, Double, Int)
        case imageFromMetadata(Int, String, String, String)
        
        var stringValue: String {
            switch self {
            
            case .photos(let lat, let lng):
                return EndPoints.base + "&api_key=\(Configuration.apiKey)" + "&lat=\(lat)&lon=\(lng)&format=json"
            
            case .photosWithPageNumber(let lat, let lon, let pageNumber):
                return EndPoints.base + "&api_key=\(Configuration.apiKey)" + "&lat=\(lat)&lon=\(lon)&page=\(pageNumber)&format=json"
            
            case .imageFromMetadata(let farmId, let serverId, let photoId, let secret):
                return "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(secret).jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getPhotosForLocation(url:URL,completion:@escaping (PhotosForLocationResponse?,Error?)->Void) -> URLSessionDataTask {
        print(url.absoluteString)
        let request = URLRequest(url:url)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error{
                print("Error: \(error)")
                
                DispatchQueue.main.async {
                    completion(nil,error)
                }
            }
            
            guard let data = data else{
                print("Error no Data")
                return
            }
            
            let decoder = JSONDecoder()
            
            do{
                //clean response
                var newDate = data.subdata(in: 14..<data.count)
                newDate.removeLast()
                print(String(data:newDate,encoding: .utf8)!)
                let photoForLocatonResponse = try decoder.decode(PhotosForLocationResponse.self, from: newDate)
                print(photoForLocatonResponse)
                DispatchQueue.main.async {
                    completion(photoForLocatonResponse,nil)
                }
                
            }catch{
                print(error)
                DispatchQueue.main.async {
                    completion(nil,error)
                }
            }
            
        }
        
        dataTask.resume()
        
        return dataTask
    }
}
