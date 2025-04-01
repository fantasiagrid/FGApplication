//
//  MotionConstants.swift
//  FG
//
//  Created by 윤서진 on 3/22/25.
// References:
// https://developer.apple.com/documentation/coremotion/getting-raw-gyroscope-events

import CoreMotion

enum AcceleratorFrequency: Int {
    // The maximum frequency at which you can request updates is hardware-dependent but is usually at least 100 Hz
    case maximum = 100
}

enum GroscopeFrequency: Int {
    // The maximum frequency at which you can request updates is hardware-dependent but is usually at least 100 Hz
    case maximum = 100
}

