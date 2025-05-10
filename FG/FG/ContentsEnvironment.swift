//
//  ContentEnvironment.swift
//  FG
//
//  Created by 윤서진 on 5/6/25.
//

import SwiftUI
import RealityFoundation

class ContentEnvironment {
    var downloadedLocation: LocationData = LocationData(latitude: 0, longitude: 0, altitude: 0)
    
    let client = WebSocketClientBuffer()
    let coordinateMapper = CoordinateMapper.shared
    
    var locationEntities: [LocationEntity] = []
    var coordiateEntiteis: [CoordinateEntity] = []
    
    private var appModel: AppModel?
    private var openImmersiveSpace: OpenImmersiveSpaceAction?
    private var dismissImmersiveSpace: DismissImmersiveSpaceAction?
}

// MARK: Space transition
extension ContentEnvironment {
    func updateSpace() async {
        guard let appModel = appModel, let open = openImmersiveSpace, let dismiss = dismissImmersiveSpace else { return }
        if await appModel.immersiveSpaceState == .open {
            await dismiss()
        }
        coordinateMapper.initRotationMatrix()
        
        let startTime = Date()
        var coordEntities: [CoordinateEntity] = []
        for locEntity in locationEntities {
            let obj_pos = coordinateMapper.calcObjectPosition(objGeographicData: locEntity.location)
            guard let obj_pos = obj_pos else { continue }
            guard let entity = try? await loadEntity(from: locEntity.url) else { return }
            coordEntities.append(CoordinateEntity(coord: obj_pos, entity: entity))
        }
        self.coordiateEntiteis = coordEntities
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        print("ImmersiveView 로딩 시간: \(duration)초")
        
        await open(id: ImmersiveSpaceID.main.rawValue)
    }
    
    func setImmersivewController(appModel: AppModel, open: OpenImmersiveSpaceAction, dismiss: DismissImmersiveSpaceAction) {
        self.appModel = appModel
        self.openImmersiveSpace = open
        self.dismissImmersiveSpace = dismiss
    }
}

// MARK: Contents
extension ContentEnvironment {
    func downloadContents(location: LocationData) {
        downloadedLocation = location
        
        // 특정 location에 해당하는 entity들을 다운로드함
        
        // client.connect()
        if BuildScheme.type == .normal {
            locationEntities = []
        } else if BuildScheme.type == .test {
            locationEntities = BuildScheme.testPoseCoordinates.objCoords
        } else {
            locationEntities = []
        }
    }
}

// MARK: Entity
extension ContentEnvironment {
    func loadEntity(from url: URL) async throws -> Entity {
        let entity = try await Entity(contentsOf: url)
        return entity
    }
}
