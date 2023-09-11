//
//  AppLog.swift
//  GasStationInfo
//
//  Created by Дмитрий Крыжановский on 09.09.2023.
//

import OSLog
import Foundation

fileprivate extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    private static var category = String(reflecting: AppLog.self)
    static let applog = Logger(subsystem: subsystem, category: category)
}

extension OSLogEntryLog.Level : CustomStringConvertible {
    public var description: String {
        switch self.rawValue {
            case 0: return "Undefined"
            case 1: return "Debug"
            case 2: return "Info"
            case 3: return "Warn"
            case 4: return "Error"
            case 5: return "Fault"
            default: return "Unknown"
        }
    }
}

struct AppLog {
    static func debug(_ message: String) {
        Logger.applog.debug("\(message, privacy: .public)")
    }

    static func info(_ message: String) {
        Logger.applog.info("\(message, privacy: .public)")
    }

    static func warn(_ message: String) {
        Logger.applog.notice("\(message, privacy: .public)")
    }

    static func error(_ message: String) {
        Logger.applog.error("\(message, privacy: .public)")
    }
    
    static func error(_ error: Error) {
        Logger.applog.error("\(String(describing: error), privacy: .public)")
    }

    static func fault(_ message: String) {
        Logger.applog.fault("\(message, privacy: .public)")
    }

    static func export(_ timeInterval: TimeInterval, _ minLevel: Int = 0) -> [String]? {
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let position = store.position(date: Date.now.addingTimeInterval(-timeInterval))
            let entries = try store.getEntries(at: position).compactMap { $0 as? OSLogEntryLog }
                .filter { $0.subsystem == Bundle.main.bundleIdentifier! && $0.level.rawValue >= minLevel }
                .map { "\($0.date.toISO8601String()) [\($0.category)] [\($0.level.description)] \($0.composedMessage)" }
            return entries
        } catch {
            AppLog.error(error)
            return nil
        }
    }
}

