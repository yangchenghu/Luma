//
//  CALayer+Animation.swift
//  DeviceUtil
//
//  Created by chengyu on 2021/6/8.
//

import Foundation
import UIKit

class CALayerNoAnimationsDelegate: NSObject, CALayerDelegate {
    static let shared = CALayerNoAnimationsDelegate()
    
    private let null = NSNull()
    
    func action(for layer: CALayer, forKey event: String) -> CAAction? { null }
}
