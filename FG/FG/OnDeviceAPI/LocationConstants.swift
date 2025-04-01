//
//  LocationConstants.swift
//  FG
//
//  Created by 윤서진 on 3/22/25.
//

import CoreLocation

enum LocationAccuracy {
    case best
    case nearestTenMeters

    var value: CLLocationAccuracy {
        switch self {
        case .best:
            // The best level of accuracy available
            // Location is updated even a small changed
            return kCLLocationAccuracyBest
        case .nearestTenMeters:
            // Accurate to within ten meters of the desired target
            // Location is updated when user moves a few meters
            return kCLLocationAccuracyNearestTenMeters
        }
    }
}
