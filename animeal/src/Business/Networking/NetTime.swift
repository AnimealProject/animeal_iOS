//
//  NetTime.swift
//  animeal
//
//  Created by Mikhail Churbanov on 5/17/23.
//

import Foundation

final class NetTime {
    public static var serverTimeDifference: TimeInterval = 0
    public static var serverNow = Date.now
    public static var now: Date {
        return Date.now - serverTimeDifference
    }
}
