//
//  HUD.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/22.
//

import UIKit
import Foundation
import ProgressHUD

class HUD: NSObject {
    
    // 基础配置，颜色
    private static func setupHud() {
        ProgressHUD.colorAnimation = .white
        ProgressHUD.colorProgress = .white
        ProgressHUD.colorBackground = .black.withAlphaComponent(0.75)
    }
    
    public static func showHud(_ msg : String? = nil) {
        Self.setupHud()
        ProgressHUD.animate(msg, .activityIndicator, interaction: false)
    }
    
    public static func hiddenHud() {
        ProgressHUD.dismiss()
    }
    
    public static func progress(_ progress : CGFloat, msg: String? = nil) {
        var p = progress
        if 0 > p {
            p = 0
        }
        else if p > 1 {
            p = 1
        }
        
        ProgressHUD.progress(msg, progress)
    }
    
    public static func progressFinish(_ msg : String? = nil) {
        ProgressHUD.succeed(msg, interaction: false, delay: 0.75)
    }
    
    
    
}

