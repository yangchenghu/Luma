//
//  Utils.swift
//  TBImageMgic
//
//  Created by xplive on 2024/7/29.
//

import UIKit
import Foundation
import Photos
import KeychainAccess

class Utils : NSObject {
    
    public static func textWidth(text : String, font : UIFont, height : CGFloat) -> CGFloat {
        guard let content = text as NSString?, !text.isEmpty else {
            return 0
        }
        
        let width : CGFloat = content.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil).size.width
        return ceil(width)
    }
    
    public static func textHeight(text : String, font : UIFont, width : CGFloat) -> CGFloat {
        
        guard let content = text as NSString?, !text.isEmpty else {
            return 0
        }
        
        let height : CGFloat = content.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil).size.height
        return ceil(height)
    }
    
    public static func impactFeedback(level: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard Thread.isMainThread, UIApplication.shared.applicationState == .active else {
            return
        }
        let generator = UIImpactFeedbackGenerator(style: level)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public static func saveVideoToAlbum(videoURL: URL, completion : ((Bool, String) -> Void)? ) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
//                print("Permission not granted")
                Thread.doInMainThread {
                    completion?(false, "Permission not granted")
                }
                return
            }
                        
            let appName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
            
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                let placeholder = request?.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: appName)
                albumChangeRequest.addAssets([placeholder] as NSFastEnumeration)
            }) { success, error in
//                if success {
//                    print("Video saved successfully")
//                } else {
//                    print("Error saving video: \(String(describing: error))")
//                }
                Thread.doInMainThread {
                    completion?(success, error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    fileprivate static var _deviceId : String?
    public static func deviceId() -> String {
        #if DEBUG
//            return "4a43d696640522bf444404a34ad0e55c"
        // 小路did
        return "f8966ba705912d131501b5614c080c64"
        #endif
        
        if let did = _deviceId {
            return did
        }
        
        let key = "com.xc.deviceid.cachekey"
        let teamId = "A442CDG6Y9"
        let shareKeyChain = "com.lumavideo.keychain.sharing"
        let groupId = teamId + "." + shareKeyChain
        
        let keyChain = Keychain(service: key, accessGroup: groupId)
        if let didData = keyChain[data: key], let didString = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSString.self, from: didData) as? String {
            debugPrint("did is:\(didString)")
            _deviceId = didString
        }
        else {
            let didString : String = UUID().uuidString.md5
            if let didData = try? NSKeyedArchiver.archivedData(withRootObject: didString, requiringSecureCoding: true) {
                keyChain[data: key] = didData
            }
            
            _deviceId = didString
        }
        
        return _deviceId!
    }
    
    
}

