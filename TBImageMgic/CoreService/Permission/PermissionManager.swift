
import Foundation
import Photos
import UIKit

class PermissionManager {
    static func checkNotification(result: ((Bool) -> Void)?) {
        UNUserNotificationCenter.current().getNotificationSettings {
            UNNotificationSettings in
            
            /// 通知是否
            let status : UNAuthorizationStatus = UNNotificationSettings.authorizationStatus
            
            /// alert 设置
            let alertSetting : UNNotificationSetting = UNNotificationSettings.alertSetting
            
            /// 锁屏设置
            let lockScreenSetting : UNNotificationSetting = UNNotificationSettings.lockScreenSetting
            
            /// 通知中心
            let notiCenterSetting : UNNotificationSetting = UNNotificationSettings.notificationCenterSetting
            
            let isOpen = (status == .authorized && (alertSetting == .enabled || lockScreenSetting == .enabled || notiCenterSetting == .enabled))
            
            Thread.doInMainThread {
                result?(isOpen)
            }
        }
    }
    
    /// 检查相册权限
    static func checkPhotoAlbum(result: ((Bool) -> Void)?, cancelBlock: (() -> Void)?) {
        func failAction() {
            AlertHelper.show(title: nil, content: "未获得相册权限，是否去设置中开启照片权限？", confirmTitle: "去设置", cancelTitle: "取消") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    cancelBlock?()
                }
            } cancelBlock: {
                cancelBlock?()
            }
        }
        
        let oldStatus = PHPhotoLibrary.authorizationStatus()
        if oldStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                Thread.doInMainThread {
                    switch status {
                    case .notDetermined:
                        result?(false)
                        failAction()
                    case .restricted:
                        result?(false)
                        failAction()
                    case .denied:
                        result?(false)
                        failAction()
                    case .authorized:
                        result?(true)
                    case .limited:
                        result?(true)
                    @unknown default:
                        Toast.showToast("图片权限请求失败")
                        result?(false)
                    }
                }
            }
        } else {
            if oldStatus == .denied {
                result?(false)
                failAction()
            } else {
                result?(true)
            }
        }
    }
    
    /// 检查相机权限
    static func checkCamera(result: ((Bool) -> Void)?, cancelBlock: (() -> Void)?) {
        func failAction() {
            AlertHelper.show(title: nil, content: "未获得摄像头权限，是否去设置中开启摄像头权限？", confirmTitle: "去设置", cancelTitle: "取消") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    cancelBlock?()
                }
            } cancelBlock: {
                cancelBlock?()
            }
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                Thread.doInMainThread {
                    result?(granted)
                    if !granted {
                        failAction()
                    }
                }
            }
        } else {
            if status == .authorized {
                result?(true)
            } else {
                result?(false)
                failAction()
            }
        }
    }
    
    /// 麦克风权限
    static func checkMicrophone() -> Bool {
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        switch microphoneStatus {
        case .authorized:
            // 用户已授予麦克风权限
            return true
        case .denied, .restricted:
            // 用户拒绝或受限制
            return false
        case .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
    
    static func requestMicrophone(result: ((Bool) -> Void)?, cancelBlock: (() -> Void)?) {
        func failAction() {
            AlertHelper.show(title: nil, content: "未获得麦克风权限，是否去设置中开启麦克风权限？", confirmTitle: "去设置", cancelTitle: "取消", confirmBlock: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    cancelBlock?()
                }
            }, parent: UIViewController.topVC()) {
                cancelBlock?()
            }
        }
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        switch microphoneStatus {
        case .authorized:
            // 用户已授予麦克风权限
            result?(true)
        case .denied, .restricted:
            // 用户拒绝或受限制
            failAction()
            result?(false)
        case .notDetermined:
            // 麦克风权限尚未确定，需要请求权限
            AVCaptureDevice.requestAccess(for: .audio) { (granted) in
                Thread.doInMainThread {
                    result?(granted)
                    if !granted {
                        // 用户拒绝了麦克风权限
                        failAction()
                    }
                }
            }
        @unknown default:
            break
        }
        
    }
    
}
