//
//  TwoRectButtonsView.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/23.
//

import UIKit
import Foundation


class TwoRectButtonsView : UIView {
    
    var backView : UIView = UIView()
    var indexView : UIView = UIView()
    var leftBtn : UIButton = UIButton(type: .custom)
    var rightBtn : UIButton = UIButton(type: .custom)
    
    var selectedIndexBlock : ((Int) -> Void )?
    
    var index : Int = 0 {
        didSet {
            selectedIndexBlock?(index)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
}

extension TwoRectButtonsView {
    func setupViews() {
        let space : CGFloat = 4
        let btnWidth : CGFloat = ceil( (frame.width - 4 - 4 - 4)*0.5 )
        let btnHeight : CGFloat = ceil( frame.height - 8 )
        
        backView.backgroundColor = UIColor(hexString: "#181629")
        backView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        backView.layer.cornerRadius = 12
        backView.layer.masksToBounds = true
        
        addSubview(backView)
        
        indexView.frame = CGRect(x: space, y: space, width: btnWidth, height: btnHeight)
        indexView.layer.cornerRadius = 8
        indexView.layer.masksToBounds = true
        indexView.backgroundColor = UIColor(hexString: "#6A74F7")
        addSubview(indexView)
        
        leftBtn.frame = CGRect(x: space, y: space, width: btnWidth, height: btnHeight)
        leftBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        leftBtn.addTarget(self, action: #selector(clickLeftAction), for: .touchUpInside)
        addSubview(leftBtn)
        
        rightBtn.frame = CGRect(x: space + btnWidth + space, y: space, width: btnWidth, height: btnHeight)
        rightBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        rightBtn.addTarget(self, action: #selector(clickRightAction), for: .touchUpInside)
        addSubview(rightBtn)
    }
    
    func layoutViews() {
        let space : CGFloat = 4
        let viewWidth : CGFloat = frame.width - 4 - 4
        let btnWidth : CGFloat = ceil( (viewWidth - space) * 0.5 )
        let btnHeight : CGFloat = ceil( frame.height - 8 )
        
        backView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        leftBtn.frame = CGRect(x: space, y: space, width: btnWidth, height: btnHeight)

        rightBtn.frame = CGRect(x: space + btnWidth + space, y: space, width: btnWidth, height: btnHeight)
        
        indexView.left = (index == 0) ? leftBtn.left : rightBtn.left
        
        leftBtn.titleLabel?.font = (index == 0) ? .systemFont(ofSize: 15, weight: .medium) : .systemFont(ofSize: 15, weight: .regular)
        
        rightBtn.titleLabel?.font = (index == 0) ? .systemFont(ofSize: 15, weight: .regular) : .systemFont(ofSize: 15, weight: .medium)
    }
    
    @objc func clickLeftAction() {
        leftBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        rightBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        
        UIView.animate(withDuration: 0.15) {
            self.indexView.left = self.leftBtn.left
        }
        index = 0
    }
    
    @objc func clickRightAction() {
        leftBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        rightBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        
        UIView.animate(withDuration: 0.15) {
            self.indexView.left = self.rightBtn.left
        }
        
        index = 1
    }
    
}


