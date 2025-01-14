//
//  Tool.swift
//  BaseExtension
//
//  Created by Howard-Zjun on 2024/08/18.
//

import UIKit

let TOP_HEIGHT: CGFloat = isiPhoneXMore ? 44 : 32

let BOTTOM_HEIGHT: CGFloat = isiPhoneXMore ? (49.5+17) : 49

public var isiPhoneXMore: Bool {
    var isMore:Bool = false
    if #available(iOS 11.0, *) {
        if let kKeyWindow {
            isMore = kKeyWindow.safeAreaInsets.bottom > 0.0
        } else {
            isMore = false
        }
    }
    return isMore
}

public var kKeyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }.first?.windows
        .filter { $0.isKeyWindow }.first
}

public var homeDirPath: String {
    NSHomeDirectory()
}

public var homeDirAt: URL {
    if #available(iOS 16.0, *) {
        return URL(filePath: homeDirPath)
    } else {
        return URL(fileURLWithPath: homeDirPath)
    }
}

public var documentsDirPath: String {
    NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
}

public var documentsDirAt: URL {
    if #available(iOS 16.0, *) {
        return URL(filePath: documentsDirPath)
    } else {
        return URL(fileURLWithPath: documentsDirPath)
    }
}

public var cachesDirPath: String {
    NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
}

public var cachesDirAt: URL {
    if #available(iOS 16.0, *) {
        return URL(filePath: cachesDirPath)
    } else {
        return URL(fileURLWithPath: cachesDirPath)
    }
}

public var tmpDirPath: String {
    NSTemporaryDirectory()
}

public var tmpDirAt: URL {
    if #available(iOS 16.0, *) {
        return URL(filePath: tmpDirPath)
    } else {
        return URL(fileURLWithPath: tmpDirPath)
    }
}

public var kAppVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
}

public var kBuildVersion: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
}

public var kDisplayName: String {
    Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
}

/// 文件复制
/// - Parameters:
///   - atPath: 源文件位置
///   - toDirPath: 要复制到的文件夹位置
///   - overwrite: 是否覆盖
///   - errorDes: 错误描述
/// - Returns: 文件复制是否成功
public func copyItem(atPath: String, toDirPath: String, overwrite: Bool, errorDes: inout Error) -> Bool {
    if !FileManager.default.fileExists(atPath: atPath) {
        return false
    }
    
    guard let atURL = URL(string: atPath) else {
        return false
    }
    
    let fileName = atURL.lastPathComponent
    
    guard let toDirPathURL = URL(string: toDirPath) else {
        return false
    }
    
    let toPath = toDirPathURL.appendingPathComponent(fileName).absoluteString
    
    return copyItem(atPath: atPath, toPath: toPath, overwrite: overwrite, errorDes: &errorDes)
}

/// 文件复制
/// - Parameters:
///   - atPath: 源文件位置
///   - toPath: 要复制到的文件位置（包含文件名）
///   - overwrite: 是否覆盖
///   - errorDes: 错误描述
/// - Returns: 文件复制是否成功
public func copyItem(atPath: String, toPath: String, overwrite: Bool, errorDes: inout Error) -> Bool {
    if !FileManager.default.fileExists(atPath: atPath) {
        return false
    }
    
    guard let toURL = URL(string: toPath) else {
        return false
    }
    
    do {
        let toURLDir = toURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: toURLDir.absoluteString) {
            try FileManager.default.createDirectory(at: toURLDir, withIntermediateDirectories: true)
        }
        
        if overwrite && FileManager.default.fileExists(atPath: toPath) {
            try FileManager.default.removeItem(atPath: toPath)
        }
        
        try FileManager.default.copyItem(atPath: atPath, toPath: toPath)
        return true
    } catch {
        errorDes = error
        print("Error \(error)")
    }
    
    return false
}



