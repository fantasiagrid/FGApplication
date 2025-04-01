//
//  ContentView.swift
//  FG
//
//  Created by 윤서진 on 2/19/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

import CoreLocation
import CoreMotion

struct ContentView: View {
    @State private var selectedVideoURL: URL?
    
    @State private var isLocationRequested = false
    @State private var isAccelerationRequested = false
    @State private var isGyroscopeRequested = false
    
    @State private var locationText = "No location data yet"
    @State private var accelerationText = "No acceleration data yet"
    @State private var gyroscopeText = "No gyroscope data yet"
    
    private let locationDataManager = LocationManager.shared
    private let motionManager = MotionManager.shared
    
    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)
            
            HStack {
                // Location
                Button(action: {
                    isLocationRequested.toggle()
                    if isLocationRequested {
                        Logger.shared.log(message: "location button was tapped! Start location updating")
                        locationDataManager.startUpdatingLocation()
                    } else {
                        Logger.shared.log(message: "location button was tapped! Stop location updating")
                        locationDataManager.stopUpdatingLocation()
                    }
                }) {
                    Text(isLocationRequested ? "Stop loc monitoring" : "Start loc monitoring")
                }
                
                // Acceleration
                Button(action: {
                    isAccelerationRequested.toggle()
                    if isAccelerationRequested {
                        Logger.shared.log(message: "acceleration button was tapped! Start acceleration updating")
                        motionManager.startUpdatingAcceleration()
                    } else {
                        Logger.shared.log(message: "acceleration button was tapped! Stop acceleration updating")
                        motionManager.requestOneAcceleration()
                    }
                }) {
                    Text(isAccelerationRequested ? "Stop acc monitoring" : "Start acc monitoring")
                }
                
                // Groscope
                Button(action: {
                    isGyroscopeRequested.toggle()
                    if isGyroscopeRequested {
                        Logger.shared.log(message: "gyroscope button was tapped! Start gyroscope updating")
                        motionManager.startUpdatingGroscope()
                    } else {
                        Logger.shared.log(message: "gyroscope button was tapped! Stop gyroscope updating")
                        motionManager.stopUpdatingGyroscope()
                    }
                }) {
                    Text(isGyroscopeRequested ? "Stop gyro monitoring" : "Start gyro monitoring")
                }
                
                // URL
                Button(action: {
                    UrlCommunicationManager.shared.communicate(
                        url: "https://www.naver.com",
                        httpMethod: "GET",
                        dataProcess: { data in
                            Logger.shared.log(message: "POST request completed. Response data: \(String(data: data, encoding: .utf8) ?? "N/A")")
                        },
                        errorProcess: { error in
                            Logger.shared.log(message: "POST request failed with error: \(error)")
                        })
                }) {
                    Text("Reqeust URL")
                }
            }
            
            Text(locationText).padding()
            Text(accelerationText).padding()
            Text(gyroscopeText).padding()
            
            ToggleImmersiveSpaceButton()
        }
        .onAppear() {
            locationDataManager.notificables.append(self)
            motionManager.notificables.append(self)
            
            changeStatus(status: locationDataManager.locationManager.authorizationStatus,
                         accuracy: locationDataManager.locationManager.accuracyAuthorization)
        }
        .padding()
    }
}

extension ContentView: NotifableLocation {
    func changeStatus(status: CLAuthorizationStatus, accuracy: CLAccuracyAuthorization) {
        switch status {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        case .notDetermined:
            locationDataManager.requestWhenInUsePermissions() // Flow 1
            break
        default:
            break
        }
        
        switch accuracy {
        case .fullAccuracy:
            print(accuracy)
            break
        case .reducedAccuracy:
            print(accuracy)
            break
        default:
            break
        }
    }
    
    func receiveLocation(data: CLLocation) {
        let locStr = "\(data.coordinate.latitude.description), \(data.coordinate.longitude.description)"
        
        locationText = "\(locStr)"
        Logger.shared.log(message: "receive location: \(locationText)")
    }
}

extension ContentView: NotifableMotion {
    func receiveAccelerationData(data: CMAccelerometerData) {
        accelerationText = "\(data.acceleration.x), \(data.acceleration.y), \(data.acceleration.z)"
        
        Logger.shared.log(message: "receive acceleration: \(accelerationText)")
    }
    
    func receiveGyroscopeData(data: CMGyroData) {
        gyroscopeText = "\(data.rotationRate.x), \(data.rotationRate.y), \(data.rotationRate.z)"
        
        Logger.shared.log(message: "receive gyroscope: \(gyroscopeText)")
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}

