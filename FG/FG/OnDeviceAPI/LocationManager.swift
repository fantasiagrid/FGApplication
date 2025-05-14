//
//  BackgroundLocationManager.swift
//  Location
//
//  Created by 윤서진 on 10/20/24.
//

import Foundation
import CoreLocation

protocol NotifableLocation {
    func changeStatus(status: CLAuthorizationStatus, accuracy: CLAccuracyAuthorization)
    func receiveLocation(data: CLLocation)
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Singleton instance
    static let shared = LocationManager()
    
    public var locationManager = CLLocationManager()
    public var notificables: [NotifableLocation] = []
    
    public var isMonitoringLocation: Bool = false
    public var startMonitoringTime: Date?
    public var stopMonitoringTime: Date?
    
    private var locationUpdateTimer: Timer?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
    }
}

// MARK: - Authorization
extension LocationManager {
    func requestWhenInUsePermissions() {
        Logger.shared.log(message: "LocationManager: Request location permission")
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Logger.shared.log(message: "LocationManager: authorization changes to: \(manager.authorizationStatus), \(manager.accuracyAuthorization)")
        
        for noti in notificables {
            noti.changeStatus(status: manager.authorizationStatus,
                              accuracy: manager.accuracyAuthorization)
        }
    }
}

// MARK: - Request one location
extension LocationManager {
    func requestOneLocation() {
        // Use this method when you want the user’s current location but do not need to leave location services running
        // This process requires time to take location maximum 10s (it can't decide which location data is the best)
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = LocationAccuracy.best.value
        fetchLocation()
    }
    
    @objc private func fetchLocation() {
        locationManager.requestLocation()
    }
}

// MARK: - Request location continuosly
extension LocationManager {
    func startRequestWithInterval(timeInterval: TimeInterval = 10.0) {
        Logger.shared.log(message: "LocationManager: startRequestWithInterval")
        
        isMonitoringLocation = true
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationUpdateTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                   target: self,
                                                   selector: #selector(fetchLocation),
                                                   userInfo: nil,
                                                   repeats: true)

        DummyFileManager.shared.location.append(date: Date(),
                                                values: ["startMonitoring", "", ""])
    }
    
    func stopRequestWithInterval() {
        Logger.shared.log(message: "LocationManager: stopRequestWithInterval")
        
        isMonitoringLocation = false
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
        
        DummyFileManager.shared.location.append(date: Date(),
                                                values: ["stopMonitoring", "", ""])
    }
    
    func startUpdatingLocation(distanceFilter: CLLocationDistance = kCLDistanceFilterNone,
                               desiredAccuracy: CLLocationAccuracy = LocationAccuracy.best.value) {
        // It takes a few seconds to get the initial location when called once. After that, the app receives the location information when the user's location exceeds the distanceFilter
        // The unit of distanceFiltert is m
        // We can't determine the frequency of requesting location, but the location is updated depending on the distanceFilter & desiredAccuracy
        isMonitoringLocation = true
        
        startMonitoringTime = Date()
        
        locationManager.distanceFilter = distanceFilter // unit: m
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.startUpdatingLocation()
        
        DummyFileManager.shared.location.startMonitoring(date: Date())
        
        if BuildScheme.type == .test {
            let loadingInterval = CoordinateSetting.loadingInterval.rawValue
            let halfLoadingTime = loadingInterval / 2
            let locInterval = loadingInterval / 10
            
            // 지금부터 1초에 한번씩 위치정보를 보냄
            for time in stride(from: 0,
                            to: loadingInterval,
                            by: locInterval) {
                let testLocation: CLLocation
                if time < halfLoadingTime {
                    testLocation = CLLocation.init(latitude: BuildScheme.testPoseCoordinates.startCoord.latitude,
                                                   longitude: BuildScheme.testPoseCoordinates.startCoord.longitude)
                } else {
                    testLocation = CLLocation.init(latitude: BuildScheme.testPoseCoordinates.moveCoord.latitude,
                                                   longitude: BuildScheme.testPoseCoordinates.moveCoord.longitude)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(time)) {
                    self.locationManager(self.locationManager,
                                         didUpdateLocations: [
                                            CLLocation.init(latitude: 0, longitude: 0),
                                            testLocation,
                                         ])
                }
            }
        }
    }
    
    func stopUpdatingLocation() {
        isMonitoringLocation = false
        
        stopMonitoringTime = Date()
        
        locationManager.stopUpdatingLocation()
        
        DummyFileManager.shared.location.stopMonitoring(date: Date())
    }
}

// MARK: - Receive location & error
extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation?
        if BuildScheme.type == .test {
            location = locations.indices.contains(1) ? locations[1] : nil
        } else {
            location = locations.first
        }
        
        guard let location = location else { return }
        for noti in notificables {
            noti.receiveLocation(data: location)
        }
        
        DummyFileManager.shared.location.append(date: Date(),
                                                values: ["receive",
                                                         location.coordinate.latitude.description,
                                                         location.coordinate.longitude.description])
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.shared.log(message: "LocationManager Manager: error: \(error.localizedDescription)")
        
        DummyFileManager.shared.location.append(date: Date(),
                                                values: [error.localizedDescription, "", ""])
    }
}

