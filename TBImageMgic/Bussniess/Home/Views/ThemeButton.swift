//
//  ThemeButton.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/13.
//

import UIKit
import Foundation

class ThemeButton : UIView {
    
    var clickBlock : (() -> Void)?
    
    var isEnabled : Bool = true {
        didSet {
            if isEnabled {
                gradientLayer.isHidden = false
            }
            else {
                gradientLayer.isHidden = true
            }
        }
    }
    
    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var font: UIFont? {
        get {
            titleLabel.font
        }
        set {
            titleLabel.font = newValue
        }
    }
    
    var titleColor: UIColor = .white {
        didSet {
            titleLabel.textColor = titleColor
        }
    }
    
    
    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x:0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1.0)
        gradientLayer.delegate = CALayerNoAnimationsDelegate.shared
        gradientLayer.position = self.center
        layer.addSublayer(gradientLayer)
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = titleColor
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        tapBlock = { [weak self] in
            self?.clickAction()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func resetUI() {
        gradientLayer.frame = bounds
        gradientLayer.position = self.center
        
        titleLabel.frame = bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resetUI()
    }
    private func clickAction() {
        guard isEnabled else { return }
        clickBlock?()
    }
    
}
