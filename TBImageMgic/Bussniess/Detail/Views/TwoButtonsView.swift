//
//  TwoButtonsView.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/23.
//

import UIKit
import Foundation


class TwoButtonsView : UIView {
    
    var backView : UIView = UIView()
    var indexView : UIView = UIView()
    var leftBtn : UIButton = UIButton(type: .custom)
    var rightBtn : UIButton = UIButton(type: .custom)
    
    var selectedIndexBlock : ((Int) -> Void )?
    
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

extension TwoButtonsView {
    func setupViews() {
        let space : CGFloat = 4
        let btnWidth : CGFloat = ceil( (frame.width - 8)*0.5 )
        let btnHeight : CGFloat = ceil( frame.height - 8 )
        
        backView.backgroundColor = UIColor(hexString: "#191919")
        backView.frame = CGRect(x: space, y: space, width: frame.width - 8, height: btnHeight)
        backView.layer.cornerRadius = btnHeight * 0.5
        backView.layer.masksToBounds = true
        
        addSubview(backView)
        
        indexView.frame = CGRect(x: space, y: space, width: btnWidth, height: btnHeight)
        indexView.layer.cornerRadius = 15
        indexView.layer.masksToBounds = true
        indexView.backgroundColor = UIColor(hexString: "#6A74F7")
        addSubview(indexView)
        
        leftBtn.frame = CGRect(x: space, y: space, width: btnWidth, height: btnHeight)
        leftBtn.setImage(UIImage(systemName: "play.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        leftBtn.addTarget(self, action: #selector(clickLeftAction), for: .touchUpInside)
        addSubview(leftBtn)
        
        rightBtn.frame = CGRect(x: space + btnWidth, y: space, width: btnWidth, height: btnHeight)
        rightBtn.setImage(UIImage(systemName: "photo.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        rightBtn.addTarget(self, action: #selector(clickRightAction), for: .touchUpInside)
        addSubview(rightBtn)
    }
    
    func layoutViews() {
        let space : CGFloat = 4
        let viewWidth : CGFloat = frame.width - 8
        let btnWidth : CGFloat = ceil( viewWidth * 0.5 )
        let btnHeight : CGFloat = ceil( frame.height - 8 )
        
        backView.frame = CGRect(x: space, y: space, width: frame.width - 8, height: btnHeight)
        
        leftBtn.frame = CGRect(x: space, y: space, width: btnWidth, height: btnHeight)

        rightBtn.frame = CGRect(x: space + btnWidth, y: space, width: btnWidth, height: btnHeight)
    }
    
    @objc func clickLeftAction() {
        UIView.animate(withDuration: 0.15) {
            self.indexView.left = self.leftBtn.left
        }
        selectedIndexBlock?(0)
    }
    
    @objc func clickRightAction() {
        UIView.animate(withDuration: 0.15) {
            self.indexView.left = self.rightBtn.left
        }
        
        
        selectedIndexBlock?(1)
    }
    
    
    
}


