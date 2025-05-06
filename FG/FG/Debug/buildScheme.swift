//
//  dd.swift
//  FG
//
//  Created by 윤서진 on 4/19/25.
//

struct BuildScheme {
    static let type: BuildSchemeType = BuildSchemeType.poseTest
    static let testPoseCoordinates: TestPoseCoordinates = .twosome_side
}

enum BuildSchemeType {
    case normal
    case poseTest
}

enum TestPoseCoordinates {
    case none
    case twosome_front
    case twosome_side
    
    var startCoord: GeographicCoordinate {
        switch self {
        case .none:
            return .init(date: nil, latitude: 0, longitude: 0, altitude: 0)
        case .twosome_side:
            return .init(date: nil, latitude: 37.565705, longitude: 127.055311, altitude: 0)
        case .twosome_front:
            return .init(date: nil, latitude: 37.565777, longitude: 127.055805, altitude: 0)
        }
        
    }
    
    var moveCoord: GeographicCoordinate {
        switch self {
        case .none:
            return .init(date: nil, latitude: 0, longitude: 0, altitude: 0)
        case .twosome_side:
            return .init(date: nil, latitude: 37.565938, longitude: 127.055577, altitude: 0)
        case .twosome_front:
            return .init(date: nil, latitude: 37.565811, longitude: 127.055449, altitude: 0)
        }
    }
    
    var objCoord: GeographicCoordinate {
        switch self {
        case .none:
            return .init(date: nil, latitude: 0, longitude: 0, altitude: 0)
        case .twosome_side:
            return .init(date: nil, latitude: 37.565898, longitude: 127.055460, altitude: 0)
        case .twosome_front:
            return .init(date: nil, latitude: 37.565898, longitude: 127.055460, altitude: 0)
        }
    }
}
