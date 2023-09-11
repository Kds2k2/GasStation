//
//  Date+ISO8601.swift
//  GasStationInfo
//
//  Created by Дмитрий Крыжановский on 09.09.2023.
//

import Foundation

extension Date {
    static func fromISO8601String(date: String) -> Date {
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso8601DateFormatter.date(from: date)!
    }

    func toISO8601String() -> String {
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso8601DateFormatter.string(from: self)
    }
}

