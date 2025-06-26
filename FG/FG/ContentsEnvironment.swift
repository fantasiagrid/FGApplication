//
//  ContentEnvironment.swift
//  FG
//
//  Created by 윤서진 on 5/6/25.
//

import SwiftUI
import RealityFoundation
import ModelIO

class ContentEnvironment {
    var downloadedLocation: LocationData = LocationData(latitude: 0, longitude: 0, altitude: 0)
    
    let client = WebSocketClientBuffer()
    let coordinateMapper: CoordinateMapper
    
    var locationEntities: [LocationEntity] = []
    var coordiateEntiteis: [CoordinateEntity] = []
    
    private var appModel: AppModel?
    private var openImmersiveSpace: OpenImmersiveSpaceAction?
    private var dismissImmersiveSpace: DismissImmersiveSpaceAction?
    
    init(coordinateMapper: CoordinateMapper) {
        self.coordinateMapper = coordinateMapper
    }
    
    private var totalVertexCount: Int {
        var nVert = 0
        for coordEntity in self.coordiateEntiteis {
            if let modelEntity = findModelEntity(in: coordEntity.entity) {
                nVert += uniqueVertexCount(from: modelEntity)
            }
        }
        return nVert
    }
}

// MARK: Space transition
extension ContentEnvironment {
    func updateSpace() async {
        // Dismiss previous immersive space
        guard let appModel = appModel, let open = openImmersiveSpace, let dismiss = dismissImmersiveSpace else { return }
        if await appModel.immersiveSpaceState == .open {
            await dismiss()
        }
        
        // Calcultae coordinate based on immersive coordinate space & Geographic location
        coordinateMapper.initRotationMatrix()
        var coordinates: [CoordinateData?] = []
        for locEntity in locationEntities {
            let obj_pos = coordinateMapper.calcObjectPosition(objGeographicData: locEntity.location)
            coordinates.append(obj_pos)
        }
        
        // Load entities
        var totalFileSize: Int64 = 0
        let loadEntityStartTime = Date()
        DummyFileManager.shared.performance.append(date: loadEntityStartTime, values: ["Start entity loading", ""])
        
        var coordEntities: [CoordinateEntity] = []
        for i in 0...coordinates.count - 1 {
            guard let coord = coordinates[i] else { continue }
            guard let entity = try? await loadEntity(from: locationEntities[i].resource) else { continue }
            guard let size = getLocalFileSize(from: locationEntities[i].resource) else { continue }
            
            let name = locationEntities[i].name
            if BuildScheme.testPoseCoordinates == .entityLoad {
                coordEntities.append(CoordinateEntity(coord: coord, entity: entity, name: name, youtubeLink: locationEntities[i].youtubeLink))
            } else {
                let xs = centeredArray(length: locationEntities.count, spacing: 1)
                coordEntities.append(CoordinateEntity(coord: CoordinateData(x: xs[i], y: 1, z: -2), entity: entity, name: name, youtubeLink: locationEntities[i].youtubeLink))
            }
            
            totalFileSize += size
        }
        
        self.coordiateEntiteis = coordEntities
        let loadEntityEndTime = Date()
        
        let convertedFileSize = convertFileSizeUnit(byte: totalFileSize, unit: "MB")
        DummyFileManager.shared.performance.append(date: loadEntityEndTime,
                                                   values: ["End entity loading", "fileSize: \(convertedFileSize)MB - #obj: \(coordEntities.count)"])
        Logger.shared.log(message: "Entity Loading duration: \(loadEntityEndTime.timeIntervalSince(loadEntityStartTime))초, fileSize: \(convertedFileSize)MB, #obj: \(coordEntities.count)")
        
        // Log: Rendering할 Vertex의 수
        if BuildScheme.type == .test {
            let startVertCalcTime = Date()
            DummyFileManager.shared.performance.append(date: startVertCalcTime, values: ["Start calc vertex", ""])
            let nVert = self.totalVertexCount
            let endVertCalcTime = Date()
            DummyFileManager.shared.performance.append(date: endVertCalcTime, values: ["End calc vertex", "total vertex: \(nVert)"])
            Logger.shared.log(message: "Total vertex count: \(nVert)")
        }
        
        // Open immersivew view
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
    func downloadInitialContents() {
        client.connect()
        // client.send(message: "")
        
        if BuildScheme.type == .normal {
            locationEntities = []
        } else if BuildScheme.type == .test {
            locationEntities = BuildScheme.testPoseCoordinates.objCoords
        } else {
            locationEntities = []
        }
    }
    
    func updateContents(location: LocationData) {
        downloadedLocation = location
    }
}

extension ContentEnvironment {
    func getLocalFileSize(from url: URL) -> Int64? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            return attr[.size] as? Int64
        } catch {
            print("파일 크기 가져오기 실패: \(error)")
            return nil
        }
    }
    
    func convertFileSizeUnit(byte: Int64, unit: String = "MB") -> Int64 {
        if unit == "KB" {
            return byte / 1024
        }
        else if unit == "MB" {
            return byte / (1024 * 1024)
        } else if unit == "GB" {
            return byte / (1024 * 1024 * 1024)
        } else {
            return 0
        }
    }
}
