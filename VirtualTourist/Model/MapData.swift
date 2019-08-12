//
//  MapData.swift
//  VirtualTourist
//
//  Created by Jerry Hanks on 12/08/2019.
//  Copyright © 2019 Jerry. All rights reserved.
//

import Foundation

struct MapData : Codable {
    let lat:Double
    let lng:Double
    let spanLatDelta:Double
    let spanLngDelta:Double
}
