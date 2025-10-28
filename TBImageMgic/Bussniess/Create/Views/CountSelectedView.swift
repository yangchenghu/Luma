//
//  CountSelectedView.swift
//  TBImageMgic
//
//  Created by xplive on 2024/7/21.
//

import UIKit
import Foundation

class CountSelectedView : UIView {
    
    var buttonCount : Int = 5 {
        didSet {
            
        }
    }
    
    var selectedIndex : Int = 0
    
    var changeBtnSelectedBlock : ((Int) -> Void)?
    
    private var btnList : [UIButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutBtns() {
        let space : CGFloat = 4
        let btnWidth : CGFloat = floor( (width - CGFloat(buttonCount - 1) * space) / CGFloat(buttonCount))
        var left : CGFloat = 0
        for index in 0..<buttonCount {
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: left, y: 0, width: btnWidth, height: height)
            btn.layer.cornerRadius = 8
            btn.layer.masksToBounds = true
            btn.layer.borderWidth = 0
            btn.layer.borderColor = UIColor(hexString: "#6E72F6")?.cgColor
            
            btn.titleLabel?.font = .systemFont(ofSize: 17)
            btn.setTitleColor(.white, for: .normal)
            btn.setTitle("\(index + 1)", for: .normal)
            btn.setTitle("\(index + 1)", for: .selected)
            btn.tag = 1000 + index
            btn.addTarget(self, action: #selector(clickBtnAction(render:)), for: .touchUpInside)
            
            left += btnWidth
            left += space
            addSubview(btn)
            btnList.append(btn)
        }
        
        refreshSeletedStatus()
    }
    
    @objc func clickBtnAction(render : UIButton) {
        let index : Int = render.tag - 1000
        selectedIndex = index
        refreshSeletedStatus()
        changeBtnSelectedBlock?(index)
    }
    
    func refreshSeletedStatus() {
        btnList.forEach { btn in
            if btn.tag - 1000 == selectedIndex {
                btn.layer.borderWidth = 1
                btn.backgroundColor = .clear
                btn.setTitleColor(UIColor(hexString: "#6E72F6"), for: .normal)
            }
            else {
                btn.layer.borderWidth = 0
                btn.backgroundColor = UIColor(hexString: "#11131f")
                btn.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    
    
    
    
    
}


