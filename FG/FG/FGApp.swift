//
//  FGApp.swift
//  FG
//
//  Created by 윤서진 on 2/19/25.
//

import SwiftUI
import CoreLocation

@main
struct FGApp: App {
    @State private var appModel = AppModel()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    let fileManager = DummyFileManager.shared
    var contentEnv: ContentEnvironment
    
    let coordinateMapper: CoordinateMapper = CoordinateMapper.shared
    
    private let locationDataManager = LocationManager.shared
    
    init() {
        contentEnv = ContentEnvironment()
        contentEnv.setImmersivewController(appModel: appModel, open: openImmersiveSpace, dismiss: dismissImmersiveSpace)
        locationDataManager.notificables.append(self)
        changeStatus(status: locationDataManager.locationManager.authorizationStatus,
                     accuracy: locationDataManager.locationManager.accuracyAuthorization)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(contentEnv: contentEnv)
                .environment(appModel)
        }
        
        ImmersiveSpace(id: ImmersiveSpaceID.main.rawValue) {
            ImmersiveView(contentEnv: contentEnv)
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
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
        contentEnv.downloadContents(location: LocationData(latitude: data.coordinate.latitude, longitude: data.coordinate.longitude, altitude: 0))
        
        coordinateMapper.receiveGeographicData(GeographicCoordinate(date: Date(),
                                                                    latitude: data.coordinate.latitude,
                                                                    longitude: data.coordinate.longitude,
                                                                    altitude: 0))
        
        Logger.shared.log(message: "receive location: \(data.coordinate.latitude), \(data.coordinate.longitude)")
    }
}
