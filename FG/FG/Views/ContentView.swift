//
//  ContentView.swift
//  FG
//
//  Created by 윤서진 on 2/19/25.
//

import SwiftUI
import RealityKit

import AudioToolbox

struct ContentView: View {
    private let contentEnv: ContentEnvironment
    
    @State private var fpsCounter = FPSCounter()
    @State private var showWebView = false
    
    init(contentEnv: ContentEnvironment) {
        self.contentEnv = contentEnv
    }

    var body: some View {
        VStack {
            VStack {
                // Start
                Button(action: {
                    Logger.shared.log(message: "Start button is tapped")
                    
                    fpsCounter.startMonitoring()
                    
                    LocationManager.shared.startUpdatingLocation()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(CoordinateSetting.loadingInterval.rawValue + 1)) {
                        Task {
                            await contentEnv.updateSpace()
                        }
                    }
                }) {
                    Text("Start")
                }
            }
        }
        .onAppear() {}
        .padding()
    }
}
