//
//  AttentionView.swift
//  ZYFiction
//
//  Created by 彭懂 on 2023/3/15.
//

import Foundation
import UIKit
import XCLocalExtension

class AttentionView: UIView {
    var cornerRadius: CGFloat = 14 {
        didSet {
            button.layer.cornerRadius = cornerRadius
        }
    }
    var font: UIFont = .pingFangMedium(size: 12) {
        didSet {
            button.titleLabel?.font = font
        }
    }
    
    var nomalText = "关注"
    
    private let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = false
        button.titleLabel?.font = font
        addSubview(button)
        resetAttentionUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let btnHeight = cornerRadius * 2
        button.frame = CGRect(x: 0, y: (bounds.height - btnHeight) / 2.0, width: bounds.width, height: btnHeight)
    }
    
    var attentionStatus: Account.AttentionStatus = .none {
        didSet {
            resetAttentionUI()
        }
    }
    
    private func resetAttentionUI() {
        switch attentionStatus {
        case .none:
            button.setImage(UIImage(named: "account_add_att"), for: .normal)
            button.setTitle(nomalText, for: .normal)
            button.setTitleColor(.Text_white1, for: .normal)
            button.backgroundColor = .Color_brand0
        case .attentioned:
            button.setImage(UIImage(named: "account_finished_att"), for: .normal)
            button.setTitle("已关注", for: .normal)
            button.setTitleColor(.Text_level3, for: .normal)
            button.backgroundColor = .Background_level2
        case .mutualAttention:
            button.setImage(UIImage(named: "account_mutual_att"), for: .normal)
            button.setTitle("互相关注", for: .normal)
            button.setTitleColor(.Text_level3, for: .normal)
            button.backgroundColor = .Background_level2
        }
    }
}
