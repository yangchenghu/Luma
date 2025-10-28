//
//  NetworkUtils.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/31.
//

import UIKit
import Foundation

class NetworkUtils : NSObject {
    
    public class func currentLanguage() -> String {
        // 返回设备曾使用过的语言列表
        let languages: [String] = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
        // 当前使用的语言排在第一
        let currentLanguage = languages.first
        return currentLanguage ?? "en-CN"
    }
    
    public static func appVersionForAPI() -> String {
        let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        var realAppVersion = ""
        let components = appVersion.components(separatedBy: ".")
        if components.count > 0 {
            for index in 0..<components.count {
                if index == 0 {
                    realAppVersion.append(String(Int(components[index]) ?? 0))
                } else {
                    realAppVersion.append("." + components[index])
                }
            }
        }
        
        return realAppVersion
    }
    
    private static var __systemVerNumber : Int64 = 0
    public static func systemVerNumber() -> Int64 {
        if __systemVerNumber != 0 {
            return __systemVerNumber
        }
        
        let ver : String = UIDevice.current.systemVersion
        var verNum : String = ver.replacingOccurrences(of: ".", with: "")

        for _ in 0..<7 {
            if verNum.count == 7 {
                break
            }
            verNum += "0"
        }
        
        __systemVerNumber =  Int64( verNum ) ?? 0
        return __systemVerNumber
    }
    
    public static func deviceId() -> String {
        Utils.deviceId()
    }
}

