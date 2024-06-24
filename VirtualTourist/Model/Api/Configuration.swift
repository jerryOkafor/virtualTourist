//
//  Configuration.swift
//  VirtualTourist
//
//  Created by Jerry Okafor on 24/06/2024.
//  Copyright © 2024 Jerry. All rights reserved.
//

import Foundation


enum Configuration{
    
    //MARK:- Public API - API Key
    static var apiKey : String{
        string(for: "API_KEY")
    }
    
    // MARK: - Helper methods
    static private func string(for key: String) -> String {
            Bundle.main.infoDictionary?[key] as! String
        }
}
