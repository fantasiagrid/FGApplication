//
//  dd.swift
//  FG
//
//  Created by 윤서진 on 4/19/25.
//

import Foundation
import CoreLocation

struct BuildScheme {
    static let type: BuildSchemeType = BuildSchemeType.test
    static let testPoseCoordinates: TestPoseCoordinates = .entityLoad
}

enum BuildSchemeType {
    case normal
    case test
}

enum TestPoseCoordinates {
    case none
    case twosome_side
    case twosome_front
    case entityLoad
    
    var startCoord: GeographicCoordinate {
        switch self {
        case .twosome_side:
            return .init(date: nil, latitude: 37.565705, longitude: 127.055311, altitude: 0)
        case .twosome_front:
            return .init(date: nil, latitude: 37.565777, longitude: 127.055805, altitude: 0)
        default:
            return .init(date: nil, latitude: 37.565777, longitude: 127.055805, altitude: 0)
        }
    }
    
    var moveCoord: GeographicCoordinate {
        switch self {
        case .twosome_side:
            return .init(date: nil, latitude: 37.565938, longitude: 127.055577, altitude: 0)
        case .twosome_front:
            return .init(date: nil, latitude: 37.565811, longitude: 127.055449, altitude: 0)
        default:
            return .init(date: nil, latitude: 37.565811, longitude: 127.055449, altitude: 0)
        }
    }
    
    var objCoords: [LocationEntity] {
        switch self {
        case .none:
            return []
        case .twosome_side:
            return [
                LocationEntity(location: LocationData(latitude: 37.565898, longitude: 127.055460, altitude: 0),
                               url: getSavingDirectory().appendingPathComponent("received_model_buffered.usdz")),
            ]
        case .twosome_front:
            return [
                LocationEntity(location: LocationData(latitude: 37.565898, longitude: 127.055460, altitude: 0),
                               url: getSavingDirectory().appendingPathComponent("received_model_buffered.usdz"))
            ]
        case .entityLoad:
            return generateNearbyEntities(center: CLLocationCoordinate2D(latitude: self.moveCoord.latitude, longitude: self.moveCoord.longitude),
                                          count: 50)
        }
    }
}

func generateNearbyEntities(center: CLLocationCoordinate2D,
                            count: Int) -> [LocationEntity] {
    var entities: [LocationEntity] = []
    let radiusInMeters: Double = 10.0

    for _ in 0..<count {
        // 임의의 각도 (0~360도)
        let angle = Double.random(in: 0..<2 * .pi)
        
        // 임의의 거리 (0~10미터)
        let distance = Double.random(in: 0...radiusInMeters)

        // 위도/경도 보정값 계산 (단순 평면 근사)
        let deltaLat = (distance * cos(angle)) / 111_111  // 1도 위도 ≈ 111.111km
        let deltaLon = (distance * sin(angle)) / (111_111 * cos(center.latitude * .pi / 180))

        let newLat = center.latitude + deltaLat
        let newLon = center.longitude + deltaLon

        let locationData = LocationData(latitude: newLat, longitude: newLon, altitude: 0)
        // let url = getSavingDirectory().appendingPathComponent("received_model_buffered.usdz")
        let url = Bundle.main.url(forResource: "blue_cat2", withExtension: "usdz")
        
        let entity = LocationEntity(location: locationData, url: url!)
        entities.append(entity)
    }

    return entities
}

func getSavingDirectory() -> URL {
    let fileManager = FileManager.default
    return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
}
