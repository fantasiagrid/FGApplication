//
//  EntityTpes.swift
//  FG
//
//  Created by 윤서진 on 5/6/25.
//

import Foundation
import RealityFoundation

struct LocationEntity {
    let location: LocationData
    let url: URL
}

struct CoordinateEntity {
    let coord: CoordinateData
    let entity: Entity
}
