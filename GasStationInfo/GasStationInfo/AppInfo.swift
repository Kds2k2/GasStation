//
//  AppInfo.swift
//  GasStationInfo
//
//  Created by Дмитрий Крыжановский on 09.09.2023.
//

import Foundation
import UIKit

struct AppInfo {
    
    //MARK: Bundle
    static var bundleName: String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
    
    static var bundleVersion: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    static var bundleBuild: String {
        return Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    }
    
    static var bundleInfo: String {
        return "\(bundleName) \(bundleVersion) (\(bundleBuild))"
    }
    
    //MARK: Device
    static var deviceName: String {
        return UIDevice.current.name
    }
    
    static var deviceType: String {
        return UIDevice.current.model
    }
    
    static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let model = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return model
    }
    
    static var deviceInfo: String {
        return "\(deviceName) \(deviceType), \(deviceModel)"
    }
    
    //MARK: System
    static var systemName: String {
        return UIDevice.current.systemName
    }
    
    static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    static var systemInfo: String {
        return "\(systemName) \(systemVersion)"
    }
    
    //MARK: Other
    static var LocaleInfo: String {
        return Locale.current.identifier
    }
    
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
