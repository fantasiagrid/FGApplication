//
//  CoordinateMapper.swift
//  FG
//
//  Created by 윤서진 on 4/12/25.
//

import Foundation
import simd

struct GeographicCoordinate {
    let date: Date?
    let latitude: Double
    let longitude: Double
    let altitude: Double
}

class CoordinateMapper {
    static let shared = CoordinateMapper()
    
    var AVP_geoGrapicCoords: [GeographicCoordinate] = []
    var AVP_geoGraphicRefCoord: GeographicCoordinate?
    
    var rotationMatrix: simd_double3x3?
    
    func receiveGeographicData(_ coord: GeographicCoordinate) {
        AVP_geoGrapicCoords.append(coord)
    }
    
    var loadingInterval: TimeInterval {
        return 1
    }
    
    private func estimatePose() -> Double? {
        guard AVP_geoGrapicCoords.count > 1 else { return nil }
        
        var startCoord: GeographicCoordinate
        var moveCoord: GeographicCoordinate
        
        let halfLoadingTime = loadingInterval / 2
        let filteredStartCoordinates: [GeographicCoordinate] = AVP_geoGrapicCoords.filter { coordinate in
            var timeInterval = coordinate.date!.timeIntervalSince(AVP_geoGrapicCoords[0].date!)
            timeInterval = Double(round(1000 * timeInterval) / 1000)
            return abs(timeInterval) < halfLoadingTime
        }
        startCoord = calculateAverageOfCoordinates(in: filteredStartCoordinates)!
        
        let filteredEndCoordinates: [GeographicCoordinate] = AVP_geoGrapicCoords.filter { coordinate in
            var timeInterval = coordinate.date!.timeIntervalSince(AVP_geoGrapicCoords.last!.date!)
            timeInterval = Double(round(1000 * timeInterval) / 1000)
            return abs(timeInterval) < halfLoadingTime
        }
        moveCoord = calculateAverageOfCoordinates(in: filteredEndCoordinates)!
        
        AVP_geoGraphicRefCoord = moveCoord
        
        DummyFileManager.shared.eventLocation.append(date: Date(),
                                                     values: ["startCoord",
                                                              startCoord.latitude.description,
                                                              startCoord.longitude.description])
        
        DummyFileManager.shared.eventLocation.append(date: Date(),
                                                     values: ["referenceCoord",
                                                              startCoord.latitude.description,
                                                              startCoord.longitude.description])
        
        let enu1SecondLater = geodeticToEnu(lat: moveCoord.latitude,
                                            lon: moveCoord.longitude,
                                            h: moveCoord.altitude,
                                            lat0: startCoord.latitude,
                                            lon0: startCoord.longitude,
                                            h0: startCoord.altitude)
        
        let theta = -atan2(enu1SecondLater.east, enu1SecondLater.north) // radian
        return theta
    }
    
    func initRotationMatrix() {
        let theta = estimatePose()
        guard let theta = theta else { return }
        
        let cosTheta = cos(theta)
        let sinTheta = sin(theta)

        let row1 = simd_double3(cosTheta, sinTheta, 0)
        let row2 = simd_double3(0, 0, 1)
        let row3 = simd_double3(sinTheta, -cosTheta, 0)
        let T = simd_double3x3(rows: [row1, row2, row3])
        
        rotationMatrix = T
    }
    
    func calcObjectPosition(objGeographicData: LocationData) -> CoordinateData? {
        guard let AVP_geoGraphicRefCoord = AVP_geoGraphicRefCoord, let T = rotationMatrix else { return nil }
        
        let enuObject = geodeticToEnu(
            lat: objGeographicData.latitude, lon: objGeographicData.longitude, h: objGeographicData.altitude,
            lat0: AVP_geoGraphicRefCoord.latitude, lon0: AVP_geoGraphicRefCoord.longitude, h0: AVP_geoGraphicRefCoord.altitude
        )
        
        let enuObjectVector = simd_double3(enuObject.east, enuObject.north, enuObject.up)
        
        let objectPositionInVisionProCoordinates = T * enuObjectVector // simd에서 행렬 * 벡터 연산
        return CoordinateData(x: objectPositionInVisionProCoordinates.x,
                              y: objectPositionInVisionProCoordinates.y,
                              z: objectPositionInVisionProCoordinates.z)
    }
    
    func calculateAverageOfCoordinates<C: Collection>(in collection: C) -> GeographicCoordinate? where C.Element == GeographicCoordinate {
        let count = collection.count // 컬렉션의 요소 개수

        // 요소가 하나도 없으면 평균 계산 불가
        guard count > 0 else {
            print("오류: 평균을 계산할 좌표가 없습니다.")
            return nil
        }

        // 위도와 경도의 합계 계산 (reduce 사용)
        let totalLatitude = collection.reduce(0.0) { $0 + $1.latitude }
        let totalLongitude = collection.reduce(0.0) { $0 + $1.longitude }

        // 평균 계산
        let averageLatitude = totalLatitude / Double(count)
        let averageLongitude = totalLongitude / Double(count)
        return GeographicCoordinate(date: nil, latitude: averageLatitude, longitude: averageLongitude, altitude: 0)
    }
}
