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
    
    private var locationUpdateTimer: Timer?
    private let locationFileManager = LocationFileManager(fileName: "location_data")
    
    
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
        locationFileManager.startMonitoring()
    }
    
    func stopRequestWithInterval() {
        Logger.shared.log(message: "LocationManager: stopRequestWithInterval")
        
        isMonitoringLocation = false
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
        locationFileManager.stopMonitoring()
    }
    
    func startUpdatingLocation(distanceFilter: CLLocationDistance = kCLDistanceFilterNone,
                               desiredAccuracy: CLLocationAccuracy = LocationAccuracy.best.value) {
        // It takes a few seconds to get the initial location when called once. After that, the app receives the location information when the user's location exceeds the distanceFilter
        // The unit of distanceFiltert is m
        // We can't determine the frequency of requesting location, but the location is updated depending on the distanceFilter & desiredAccuracy
        isMonitoringLocation = true
        
        locationManager.distanceFilter = distanceFilter
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.startUpdatingLocation()
        
        locationFileManager.startMonitoring()
    }
    
    func stopUpdatingLocation() {
        isMonitoringLocation = false
        
        locationManager.stopUpdatingLocation()
        
        locationFileManager.stopMonitoring()
    }
}

// MARK: - Receive location & error
extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            for noti in notificables {
                noti.receiveLocation(data: location)
            }
            
            locationFileManager.recordLocationData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.shared.log(message: "LocationManager Manager: error: \(error.localizedDescription)")
        locationFileManager.saveError(description: error.localizedDescription)
    }
}

