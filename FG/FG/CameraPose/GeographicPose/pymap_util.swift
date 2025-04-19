//
//  pymap_util.swift
//  FG
//
//  Created by 윤서진 on 4/12/25.
//

import Foundation

struct Model {
    let name: String
    let a: Double // Semi-major axis
    let b: Double // Semi-minor axis
}

struct Ellipsoid {
    // 저장 프로퍼티
    let model: String         // 짧은 이름 (예: "wgs84")
    let name: String          // 설명적인 이름 (예: "WGS-84 (1984)")
    let semimajorAxis: Double // 장반경 (미터 단위)
    let semiminorAxis: Double // 단반경 (미터 단위)

    // 계산 프로퍼티 (초기화 시 계산됨)
    let flattening: Double      // 편평률 f = (a-b)/a
    let thirdFlattening: Double // 제3 편평률 n = (a-b)/(a+b)
    let eccentricity: Double    // 이심률 e = sqrt(2f - f^2)

    // 정적 프로퍼티로 모델 데이터 저장 (Python의 클래스 변수와 유사)
    static let models: [String: Model] = [
        // 지구 타원체들
        "maupertuis": Model(name: "Maupertuis (1738)", a: 6397300.0, b: 6363806.283),
        "plessis": Model(name: "Plessis (1817)", a: 6376523.0, b: 6355862.9333),
        "everest1830": Model(name: "Everest (1830)", a: 6377299.365, b: 6356098.359),
        "everest1830m": Model(name: "Everest 1830 Modified (1967)", a: 6377304.063, b: 6356103.039),
        "everest1967": Model(name: "Everest 1830 (1967 Definition)", a: 6377298.556, b: 6356097.55),
        "airy": Model(name: "Airy (1830)", a: 6377563.396, b: 6356256.909),
        "bessel": Model(name: "Bessel (1841)", a: 6377397.155, b: 6356078.963),
        "clarke1866": Model(name: "Clarke (1866)", a: 6378206.4, b: 6356583.8),
        "clarke1878": Model(name: "Clarke (1878)", a: 6378190.0, b: 6356456.0),
        "clarke1860": Model(name: "Clarke (1880)", a: 6378249.145, b: 6356514.87),
        "helmert": Model(name: "Helmert (1906)", a: 6378200.0, b: 6356818.17),
        "hayford": Model(name: "Hayford (1910)", a: 6378388.0, b: 6356911.946),
        "international1924": Model(name: "International (1924)", a: 6378388.0, b: 6356911.946),
        "krassovsky1940": Model(name: "Krassovsky (1940)", a: 6378245.0, b: 6356863.019),
        "wgs66": Model(name: "WGS66 (1966)", a: 6378145.0, b: 6356759.769),
        "australian": Model(name: "Australian National (1966)", a: 6378160.0, b: 6356774.719),
        "international1967": Model(name: "New International (1967)", a: 6378157.5, b: 6356772.2),
        "grs67": Model(name: "GRS-67 (1967)", a: 6378160.0, b: 6356774.516),
        "sa1969": Model(name: "South American (1969)", a: 6378160.0, b: 6356774.719),
        "wgs72": Model(name: "WGS-72 (1972)", a: 6378135.0, b: 6356750.52001609),
        "grs80": Model(name: "GRS-80 (1979)", a: 6378137.0, b: 6356752.31414036),
        "wgs84": Model(name: "WGS-84 (1984)", a: 6378137.0, b: 6356752.31424518),
        "wgs84_mean": Model(name: "WGS-84 (1984) Mean", a: 6371008.7714, b: 6371008.7714), // 구에 가까움
        "iers1989": Model(name: "IERS (1989)", a: 6378136.0, b: 6356751.302),
        "pz90.11": Model(name: "ПЗ-90 (2011)", a: 6378136.0, b: 6356751.3618),
        "iers2003": Model(name: "IERS (2003)", a: 6378136.6, b: 6356751.9),
        "gsk2011": Model(name: "ГСК (2011)", a: 6378136.5, b: 6356751.758),
        // 다른 천체들
        "mercury": Model(name: "Mercury", a: 2440500.0, b: 2438300.0),
        "venus": Model(name: "Venus", a: 6051800.0, b: 6051800.0),
        "moon": Model(name: "Moon", a: 1738100.0, b: 1736000.0),
        "mars": Model(name: "Mars", a: 3396900.0, b: 3376097.80585952),
        "jupyter": Model(name: "Jupiter", a: 71492000.0, b: 66770054.3475922),
        "io": Model(name: "Io", a: 1829.7 * 1000, b: 1815.8 * 1000), // 단위를 미터로 통일 (원본은 km로 추정)
        "saturn": Model(name: "Saturn", a: 60268000.0, b: 54364301.5271271),
        "uranus": Model(name: "Uranus", a: 25559000.0, b: 24973000.0),
        "neptune": Model(name: "Neptune", a: 24764000.0, b: 24341000.0),
        "pluto": Model(name: "Pluto", a: 1188000.0, b: 1188000.0),
    ]

    /**
     타원체 모델을 초기화합니다.

     - Parameters:
       - semimajorAxis: 장반경 (미터 단위)
       - semiminorAxis: 단반경 (미터 단위)
       - name: 타원체의 설명적인 이름 (옵션)
       - model: 타원체의 짧은 이름 (옵션)
     */
    init(semimajorAxis: Double, semiminorAxis: Double, name: String = "", model: String = "") {
        let a = semimajorAxis
        let b = semiminorAxis

        let f = (a - b) / a
        // 편평률은 0보다 크거나 같아야 합니다.
        // Swift에서는 precondition 또는 assertionFailure를 사용할 수 있습니다.
        // precondition은 Release 빌드에서도 검사하며, 실패 시 앱을 종료시킵니다.
        // assertionFailure는 Debug 빌드에서만 검사하며, 실패 시 앱을 중단시킵니다.
        precondition(f >= 0, "Flattening must be non-negative.")

        self.semimajorAxis = a
        self.semiminorAxis = b
        self.name = name
        self.model = model

        // 계산된 프로퍼티 초기화
        self.flattening = f
        self.thirdFlattening = (a - b) / (a + b)
        self.eccentricity = sqrt(2 * f - pow(f, 2)) // pow(f, 2) == f * f
    }

    /**
     사전 정의된 모델 이름으로부터  인스턴스를 생성합니다.

     - Parameter name: 사용할 모델의 짧은 이름 (예: "wgs84")
     - Returns: 해당 모델의 Ellipsoid 인스턴스. 모델이 없으면 fatalError 발생.
     */
    static func from(modelName: String) -> Ellipsoid {
        guard let modelData = models[modelName] else {
            fatalError("Ellipsoid model named '\(modelName)' not found.")
        }
        return Ellipsoid(
            semimajorAxis: modelData.a,
            semiminorAxis: modelData.b,
            name: modelData.name,
            model: modelName
        )
    }
}
