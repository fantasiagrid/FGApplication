//
//  Date_util.swift
//  FG
//
//  Created by 윤서진 on 4/16/25.
//

import Foundation

func averageDate(from dates: [Date]) -> Date? {
    guard !dates.isEmpty else {
        return nil // 빈 배열인 경우 nil 반환
    }

    let totalTimeInterval = dates.reduce(0, { (sum, date) in
        return sum + date.timeIntervalSinceReferenceDate
    })

    let averageTimeInterval = totalTimeInterval / Double(dates.count)

    return Date(timeIntervalSinceReferenceDate: averageTimeInterval)
}
