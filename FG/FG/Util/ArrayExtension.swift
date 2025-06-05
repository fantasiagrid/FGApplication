//
//  Util.swift
//  FG
//
//  Created by 윤서진 on 6/4/25.
//

func centeredArray(length: Int, spacing: Float) -> [Float] {
    guard length > 0 else { return [] }

    let mid = length / 2
    return (0..<length).map { i in
        Float(i - mid) * Float(spacing)
    }
}
