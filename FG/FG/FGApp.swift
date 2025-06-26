//
//  FGApp.swift
//  FG
//
//  Created by 윤서진 on 2/19/25.
//

import SwiftUI
import CoreLocation
import AudioToolbox

@main
struct FGApp: App {
    @State private var appModel = AppModel()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    let fileManager = DummyFileManager.shared
    var contentEnv: ContentEnvironment
    
    let coordinateMapper: CoordinateMapper = CoordinateMapper()
    
    private let locationDataManager = LocationManager.shared
    private let poseProvider = DevicePoseProvider()
    
    init() {
        contentEnv = ContentEnvironment(coordinateMapper: coordinateMapper)
        contentEnv.setImmersivewController(appModel: appModel, open: openImmersiveSpace, dismiss: dismissImmersiveSpace)
        contentEnv.downloadInitialContents()
        
        locationDataManager.notificables.append(self)
        poseProvider.notificables.append(self)
        changeStatus(status: locationDataManager.locationManager.authorizationStatus,
                     accuracy: locationDataManager.locationManager.accuracyAuthorization)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(contentEnv: contentEnv)
                .environment(appModel)
        }.windowStyle(.plain)
        
        WindowGroup(id: WindowID.web.rawValue, for: String.self) { value in
            WebContentView()
        }
        
        ImmersiveSpace(id: ImmersiveSpaceID.main.rawValue) {
            ImmersiveView(contentEnv: contentEnv)
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                    
                    poseProvider.runSession()
                    poseProvider.startTracking()
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}

extension FGApp: NotifableLocation {
    func changeStatus(status: CLAuthorizationStatus, accuracy: CLAccuracyAuthorization) {
        if status == .notDetermined {
            locationDataManager.requestWhenInUsePermissions() // Flow 1
         }
    }
    
    func receiveLocation(data: CLLocation) {
        contentEnv.updateContents(location: LocationData(latitude: data.coordinate.latitude, longitude: data.coordinate.longitude, altitude: 0))
        
        coordinateMapper.receiveGeographicData(GeographicCoordinate(date: Date(),
                                                                    latitude: data.coordinate.latitude,
                                                                    longitude: data.coordinate.longitude,
                                                                    altitude: 0))
        
        Logger.shared.log(message: "receive location: \(data.coordinate.latitude), \(data.coordinate.longitude)")
    }
}

extension FGApp: NotifablePose {
    func receiveRotation(data: Rotation) {
        if data.yaw > 0 && data.yaw > 90 {
            AudioServicesPlaySystemSound(1057)
            DummyFileManager.shared.performance.append(date: Date(),
                                                       values: ["Left(90)", ""])
        }
        if data.yaw < 0 && data.yaw < -90 {
            DummyFileManager.shared.performance.append(date: Date(),
                                                       values: ["Right(90)", ""])
            AudioServicesPlaySystemSound(1057)
        }
    }
}
