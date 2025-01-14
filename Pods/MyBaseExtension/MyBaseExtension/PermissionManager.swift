//
//  PermissionManager.swift
//  BaseExtension
//
//  Created by Howard-Zjun on 2024/08/18.
//

import UIKit
import Photos
import EventKit
import Contacts

public extension NSObject {
    
    func toSetting(title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let toSettingAction = UIAlertAction(title: "去设置", style: .default) { action in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        vc.addAction(cancelAction)
        vc.addAction(toSettingAction)
        if let kKeyWindow {
            kKeyWindow.rootViewController?.present(vc, animated: true)
        }
    }
    
    // MARK: - 相册权限
    /// 申请相册权限
    func requestPhotoPermission(_ block: @escaping ((PHAuthorizationStatus) -> Void)) {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        
        if status == .notDetermined { // 未确定
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
                    DispatchQueue.main.async {
                        self.requestPhotoPermission(block)
                    }
                }
            } else {
                PHPhotoLibrary.requestAuthorization { _ in
                    DispatchQueue.main.async {
                        self.requestPhotoPermission(block)
                    }
                }
            }
        } else if status == .restricted { // 没有访问权限
            block(.restricted)
        } else if status == .authorized { // 已授权
            block(.authorized)
        } else if status == .denied { // 已禁止
            block(.denied)
        } else {
            if #available(iOS 14, *) {
                if status == .limited { // 有限授权
                    block(.limited)
                }
            }
        }
    }
    
    /// 申请相册权限带成功回调
    func requestPhotoPermissionWith(successBlock: @escaping (() -> Void)) {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        
        let firstRequest = status == .notDetermined
        requestPhotoPermission { [weak self] status in
            if status == .authorized {
                successBlock()
            } else if !firstRequest {
                self?.toSetting(title: "提示", message: "相册未授权，需要去设置进行修改")
            }
        }
    }
    
    // MARK: - 相机权限
    /// 申请相机权限
    func requestCameraPremission(_ block: @escaping ((AVAuthorizationStatus) -> Void)) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { _ in
                DispatchQueue.main.async {
                    self.requestCameraPremission(block)
                }
            }
        } else if status == .authorized {
            block(.authorized)
        } else if status == .denied {
            block(.denied)
        } else if status == .restricted {
            block(.restricted)
        }
    }
    
    /// 申请相机权限带成功回调
    func requestCameraPermissionWith(successBlock: @escaping (() -> Void)) {
        let firstRequest = AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
        
        requestCameraPremission { [weak self] status in
            if status == .authorized {
                successBlock()
            } else if !firstRequest {
                self?.toSetting(title: "提示", message: "相机未授权，需要去设置进行修改")
            }
        }
    }
    
    // MARK: - 日历权限
    /// 申请日历权限
    func requestCalendarPermission(_ block: @escaping ((EKAuthorizationStatus) -> Void)) {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        if status == .notDetermined {
            if #available(iOS 17, *) {
                EKEventStore().requestFullAccessToEvents { _, error in
                    if let error {
                        print("Error \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.requestCalendarPermission(block)
                        }
                    }
                }
            } else {
                EKEventStore().requestAccess(to: .event) { result, error in
                    if let error {
                        print("Error \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.requestCalendarPermission(block)
                        }
                    }
                }
            }
        } else if status == .authorized {
            block(.authorized)
        } else if status == .denied {
            block(.denied)
        } else if status == .restricted {
            block(.restricted)
        } else {
            if #available(iOS 17, *) {
                if status == .fullAccess {
                    block(.fullAccess)
                } else if status == .writeOnly {
                    block(.writeOnly)
                }
            }
        }
    }
    
    /// 申请日历权限带成功回调
    func requestCalendarPermisstionWith(successBlock: @escaping (() -> Void)) {
        let firstRequest = EKEventStore.authorizationStatus(for: .event) == .notDetermined
        
        requestCalendarPermission { [weak self] status in
            if #available(iOS 17, *) {
                if status == .writeOnly || status == .fullAccess {
                    successBlock()
                } else if !firstRequest {
                    self?.toSetting(title: "提示", message: "日历未授权，需要去设置进行修改")
                }
            } else {
                if status == .authorized {
                    successBlock()
                } else if !firstRequest {
                    self?.toSetting(title: "提示", message: "日历未授权，需要去设置进行修改")
                }
            }
        }
    }
    
    
    // MARK: - 麦克风权限
    /// 申请麦克风权限
    func requestMicrophonePermission(_ block: @escaping ((AVAuthorizationStatus) -> Void)) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .audio) { _ in
                DispatchQueue.main.async {
                    self.requestMicrophonePermission(block)
                }
            }
        } else if status == .authorized {
            block(.authorized)
        } else if status == .denied {
            block(.denied)
        } else if status == .restricted {
            block(.restricted)
        }
    }
    
    /// 申请麦克风权限带成功回调
    func requestMicrophonePermisstionWith(successBlock: @escaping (() -> Void)) {
        let firstRequest = AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined
        
        requestMicrophonePermission { [weak self] status in
            if status == .authorized {
                successBlock()
            } else if !firstRequest {
                self?.toSetting(title: "提示", message: "麦克风未授权，需要去设置进行修改")
            }
        }
    }
    
    /// 申请定位权限，这个比较特俗，通过委托回调，这里不写通用的
//    func requestLocationPremission(_ block: @escaping (() -> Void)) {
//        let manager = CLLocationManager()
//        manager.delegate = self
//        let status: CLAuthorizationStatus
//        if #available(iOS 14, *) {
//            status = manager.authorizationStatus
//        } else {
//            status = CLLocationManager.authorizationStatus()
//        }
//        
//        if status == .notDetermined {
//            manager.requestWhenInUseAuthorization()
//        } else if status == .authorizedAlways {
//            
//        } else if status == .authorizedWhenInUse {
//            
//        } else if status == .denied {
//            
//        } else if status == .restricted {
//            
//        }
//    }
    
    // MARK: - 申请人权限
    /// 申请联系人权限
    func requestContactPremission(_ block: @escaping ((CNAuthorizationStatus) -> Void)) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        if status == .notDetermined {
            CNContactStore().requestAccess(for: .contacts) { _, error in
                if let error {
                    print("Error \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.requestContactPremission(block)
                    }
                }
            }
        } else if status == .authorized {
            block(.authorized)
        } else if status == .denied {
            block(.denied)
        } else if status == .restricted {
            block(.restricted)
        }
    }
    
    /// 申请联系人权限带成功回调
    func requestContactPermisstionWith(successBlock: @escaping (() -> Void)) {
        let firstRequest = CNContactStore.authorizationStatus(for: .contacts) == .notDetermined
        
        requestContactPremission { [weak self] status in
            if status == .authorized {
                successBlock()
            } else if !firstRequest {
                self?.toSetting(title: "提示", message: "联系人未授权，需要去设置进行修改")
            }
        }
    }
}
