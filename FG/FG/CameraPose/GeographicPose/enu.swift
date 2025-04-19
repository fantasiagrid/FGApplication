//
//  enu.swift
//  FG
//
//  Created by 윤서진 on 4/12/25.
//

import Foundation

// 기본 타원체 설정 (WGS84)
let defaultEllipsoid = Ellipsoid.from(modelName: "wgs84")

private func degreesToRadians(_ degrees: Double) -> Double {
    return degrees * .pi / 180.0
}

/**
 지정된 타원체(기본값 WGS-84)의 측지 좌표(위도, 경도, 고도)를 ECEF(지구 중심, 지구 고정) 좌표로 변환합니다.

 - Parameters:
   - lat: 목표 지점의 측지 위도
   - lon: 목표 지점의 측지 경도
   - alt: 타원체 상공 고도 (미터 단위)
   - ell: 사용할 참조 타원체 (기본값: WGS-84)
   - deg: 입력 위도/경도가 도(degree) 단위인지 여부 (기본값: true). false이면 라디안(radian) 단위로 간주합니다.
 - Returns: ECEF 좌표 (x, y, z) 튜플 (미터 단위)
 */
func geodeticToEcef(
    lat: Double,
    lon: Double,
    alt: Double,
    ell: Ellipsoid = defaultEllipsoid,
    deg: Bool = true
) -> (x: Double, y: Double, z: Double) {

    let latitude = deg ? degreesToRadians(lat) : lat
    let longitude = deg ? degreesToRadians(lon) : lon

    let a = ell.semimajorAxis
    let b = ell.semiminorAxis

    // 묘유선(prime vertical)의 곡률 반경 N
    // hypot(x, y)는 sqrt(x*x + y*y)와 같습니다.
    let N = pow(a, 2) / hypot(a * cos(latitude), b * sin(latitude))

    // 측지 좌표를 데카르트(지심) 좌표로 변환
    let x = (N + alt) * cos(latitude) * cos(longitude)
    let y = (N + alt) * cos(latitude) * sin(longitude)
    let z = (N * pow(b / a, 2) + alt) * sin(latitude)

    return (x, y, z)
}

/**
 ECEF 좌표계에서의 벡터 (u, v, w)를 특정 위치(lat0, lon0)에서의 ENU(동, 북, 상) 좌표계로 변환합니다.
 이 함수는 주로 두 ECEF 지점 간의 차이 벡터를 로컬 ENU 좌표로 변환하는 데 사용됩니다.

 - Parameters:
   - u: 목표 지점의 ECEF x 좌표 (또는 차이 벡터의 x 성분) (미터)
   - v: 목표 지점의 ECEF y 좌표 (또는 차이 벡터의 y 성분) (미터)
   - w: 목표 지점의 ECEF z 좌표 (또는 차이 벡터의 z 성분) (미터)
   - lat0: 관측자(기준점)의 측지 위도
   - lon0: 관측자(기준점)의 측지 경도
   - deg: 입력 위도/경도가 도(degree) 단위인지 여부 (기본값: true). false이면 라디안(radian) 단위로 간주합니다.
 - Returns: ENU 좌표 (east, north, up) 튜플 (미터 단위)
 */
func uvwToEnu(
    u: Double,
    v: Double,
    w: Double,
    lat0: Double,
    lon0: Double,
    deg: Bool = true
) -> (east: Double, north: Double, up: Double) {

    let latitude0 = deg ? degreesToRadians(lat0) : lat0
    let longitude0 = deg ? degreesToRadians(lon0) : lon0

    let cosLon = cos(longitude0)
    let sinLon = sin(longitude0)
    let cosLat = cos(latitude0)
    let sinLat = sin(latitude0)

    // 회전 변환 적용
    let t = cosLon * u + sinLon * v
    let east = -sinLon * u + cosLon * v
    let up = cosLat * t + sinLat * w
    let north = -sinLat * t + cosLat * w

    return (east, north, up)
}

/**
 목표 지점의 측지 좌표를 관측자 기준의 ENU(동, 북, 상) 좌표로 변환합니다.

 - Parameters:
   - lat: 목표 지점의 측지 위도
   - lon: 목표 지점의 측지 경도
   - h: 목표 지점의 타원체 상공 고도 (미터)
   - lat0: 관측자의 측지 위도
   - lon0: 관측자의 측지 경도
   - h0: 관측자의 타원체 상공 고도 (미터)
   - ell: 사용할 참조 타원체 (기본값: WGS-84)
   - deg: 입력 위도/경도가 도(degree) 단위인지 여부 (기본값: true). false이면 라디안(radian) 단위로 간주합니다.
 - Returns: ENU 좌표 (east, north, up) 튜플 (미터 단위)
 */
func geodeticToEnu(
    lat: Double,
    lon: Double,
    h: Double,
    lat0: Double,
    lon0: Double,
    h0: Double,
    ell: Ellipsoid = defaultEllipsoid,
    deg: Bool = true
) -> (east: Double, north: Double, up: Double) {

    // 1. 목표 지점과 관측자 지점을 ECEF 좌표로 변환
    let (xTarget, yTarget, zTarget) = geodeticToEcef(lat: lat, lon: lon, alt: h, ell: ell, deg: deg)
    let (xObserver, yObserver, zObserver) = geodeticToEcef(lat: lat0, lon: lon0, alt: h0, ell: ell, deg: deg)

    // 2. ECEF 좌표계에서 관측자로부터 목표 지점까지의 차이 벡터 계산 (u, v, w)
    let u = xTarget - xObserver
    let v = yTarget - yObserver
    let w = zTarget - zObserver

    // 3. 차이 벡터 (u, v, w)를 관측자 위치에서의 ENU 좌표로 변환
    return uvwToEnu(u: u, v: v, w: w, lat0: lat0, lon0: lon0, deg: deg)
}
