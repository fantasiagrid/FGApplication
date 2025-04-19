//
//  FGApp.swift
//  FG
//
//  Created by 윤서진 on 2/19/25.
//

import SwiftUI

@main
struct FGApp: App {
    @State private var appModel = AppModel()
    @Environment(\.scenePhase) private var scenePhase
    let fileManager = DummyFileManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                Logger.shared.log(message: "App is active")
            case .inactive:
                Logger.shared.log(message: "App is inactive")
                stopSensors()
            case .background:
                Logger.shared.log(message: "App moved to background")
                stopSensors()
                
            @unknown default:
                break
            }
        }
     }
    
    func stopSensors() {
        if LocationManager.shared.isMonitoringLocation {
            LocationManager.shared.stopUpdatingLocation()
        }
        if MotionManager.shared.isMonitoringAcceleration {
            MotionManager.shared.stopUpdatingAcceleration()
        }
        if MotionManager.shared.isMonitoringGyroscope {
            MotionManager.shared.stopUpdatingGyroscope()
        }
    }
}

