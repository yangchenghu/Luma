//
//  Toast.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/21.
//

import UIKit
import Foundation
import Toast_Swift

class Toast : NSObject {
    
    public static func showToast(_ msg : String) {
        guard let window = UIApplication.shared.delegate?.window else {
            return
        }
        
        window?.makeToast(msg, duration: 2, position: .center)
    }
    
    
}

