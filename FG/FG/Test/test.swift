//
//  coord2render.swift
//  FG
//
//  Created by 윤서진 on 3/26/25.
//

import Foundation
import simd

// 위치정보를 알고있다는가정

// 위치정보 1:
// 위치정보 2:

// WGS84 constants
let a: Double = 6378137.0  // Earth's semi-major axis in meters
let f: Double = 1 / 298.257223563  // Flattening
let e2: Double = 2 * f - f * f  // Eccentricity squared

var lat_ref = 37.5626227
var lon_ref = 127.0515484
var alt_ref = 0

var lat = 37.56269386
var lon = 127.0515787
var alt = 0

var o_lat = 37.5627226
var o_lon = 127.0516315
var o_alt = 0
                                                                
// Normalize a vector
func normalizeVector(vector: simd_double3) -> simd_double3 {
    let magnitude = simd_length(vector)
    
    if magnitude == 0 {
        return simd_double3(0, 0, 0)  // Avoid division by zero for zero vectors
    } else {
        return vector / magnitude
    }
}

// Compute the camera rotation matrix
func computeCameraRotation(direction: simd_double3,
                           up: simd_double3 = simd_double3(0, 0, 1)) -> (simd_double3, simd_double3x3) {
    // direction: ecf2enu (device - gps1, device- gps2)
    // up: 상수
    // output: 3x3 rotation matrix
    
    let d = direction
    let norm_d = simd_length(d)
    
    if norm_d < 1e-6 {
        fatalError("Input direction vector is too short.")
    }
    let normalizedDirection = d / norm_d
    
    // In Blender, the camera's default view direction is along the -Z axis.
    let localZ = -normalizedDirection
    
    // Compute the right vector as the cross product of the 'up' vector and localZ.
    var right = simd_cross(up, localZ)
    let normRight = simd_length(right)
    
    if normRight < 1e-6 {
        let upAlt = simd_double3(0, 1, 0)
        right = simd_cross(upAlt, localZ)
    }
    
    let normalizedRight = right / simd_length(right)
    
    // Compute the true up vector as the cross product of localZ and right.
    let trueUp = simd_cross(localZ, normalizedRight)
    
    // Construct the rotation matrix with columns: right, trueUp, and localZ.
    let R = simd_double3x3(right, trueUp, localZ)
    
    return (normalizedDirection, R)
}

// Get intrinsic matrix
func getIntrinsic() -> simd_double3x3 {
    let focalLengthX: Double = 10000
    let focalLengthY: Double = 10000
    let cx: Double = 512
    let cy: Double = 480
    
    // Create a matrix by assigning each row separately
    return simd_double3x3(
        simd_double3(focalLengthX, 0, cx),
        simd_double3(0, focalLengthY, cy),
        simd_double3(0, 0, 1)
    )
}

// Function to convert degrees to radians
func degToRad(deg: Double) -> Double {
    return deg * .pi / 180
}

// Convert geodetic coordinates to ECEF coordinates
func geodeticToECEF(lat: Double, lon: Double, alt: Double) -> simd_double3 {
    let latRad = degToRad(deg: lat)
    let lonRad = degToRad(deg: lon)
    
    let N = a / sqrt(1 - e2 * sin(latRad) * sin(latRad))  // Prime vertical radius of curvature
    let X = (N + alt) * cos(latRad) * cos(lonRad)
    let Y = (N + alt) * cos(latRad) * sin(lonRad)
    let Z = (N * (1 - e2) + alt) * sin(latRad)
    
    return simd_double3(X, Y, Z)
}

// GPS z: 0
// object z: 있을 수 있음

// Convert ECEF coordinates to ENU
func ecefToENU(latRef: Double, lonRef: Double, altRef: Double,
               lat: Double, lon: Double, alt: Double) -> simd_double3 {
    /*
     Ref: reference 좌표
     lat, long, alt: object gps 좌표 or gps2
     
     return delta
     
     -
     ENU: reference 기준 좌표계
     비전프로 좌표계: 디바이스 기준 상대 좌표계
     */
    let refECEF = geodeticToECEF(lat: latRef, lon: lonRef, alt: altRef)
    let targetECEF = geodeticToECEF(lat: lat, lon: lon, alt: alt)
    
    // Differences in ECEF coordinates
    let dX = targetECEF.x - refECEF.x
    let dY = targetECEF.y - refECEF.y
    let dZ = targetECEF.z - refECEF.z
    
    // Convert reference point to radians
    let latRefRad = degToRad(deg: latRef)
    let lonRefRad = degToRad(deg: lonRef)
    
    // Rotation matrix components
    let sinLat = sin(latRefRad)
    let cosLat = cos(latRefRad)
    let sinLon = sin(lonRefRad)
    let cosLon = cos(lonRefRad)
    
    // Calculate ENU coordinates
    let east = -sinLon * dX + cosLon * dY
    let north = -sinLat * cosLon * dX - sinLat * sinLon * dY + cosLat * dZ
    let up = cosLat * cosLon * dX + cosLat * sinLon * dY + sinLat * dZ
    
    return simd_double3(east, north, up)
}
