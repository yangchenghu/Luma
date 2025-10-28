
import UIKit
import Foundation


class DetailUpDownView : UIView {
    
    let titleLabel : UILabel = UILabel()
    let leftLine : UIView = UIView()
    let rightLine : UIView = UIView()
    
    let upBtn : UIButton = UIButton(type: .custom)
    let downBtn : UIButton = UIButton(type: .custom)
    
    var clickUpBlock : ( () -> Void )?
    var clickDownBlock : ( () -> Void )?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()    
        layoutViews()
    }
}

extension DetailUpDownView {
    func setupViews() {
        leftLine.backgroundColor = .white.withAlphaComponent(0.24)
        addSubview(leftLine)
        rightLine.backgroundColor = .white.withAlphaComponent(0.24)
        addSubview(rightLine)
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white.withAlphaComponent(0.6)
        titleLabel.text = localizedStr("做的怎么样")
        addSubview(titleLabel)
        
        upBtn.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        upBtn.backgroundColor = UIColor(hexString: "#787880")?.withAlphaComponent(0.2)
        upBtn.layer.cornerRadius = 32
        upBtn.layer.masksToBounds = true
        upBtn.setImage(UIImage(systemName: "hand.thumbsup.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        upBtn.addTarget(self, action: #selector(clickUpAction), for: .touchUpInside)
        addSubview(upBtn)
        
        downBtn.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        downBtn.backgroundColor = UIColor(hexString: "#787880")?.withAlphaComponent(0.2)
        downBtn.layer.cornerRadius = 32
        downBtn.layer.masksToBounds = true
        downBtn.setImage(UIImage(systemName: "hand.thumbsdown.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        downBtn.addTarget(self, action: #selector(clickDownAction), for: .touchUpInside)
        addSubview(downBtn)
    }
    
    func layoutViews() {
        
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: ( (width - titleLabel.width) * 0.5 ), y: 0, width: titleLabel.width, height: 18)
        
        leftLine.frame = CGRect(x: titleLabel.left - 12 - 55, y: 8, width: 55, height: 0.5)
        
        rightLine.frame = CGRect(x: titleLabel.right + 12, y: 8, width: 55, height: 0.5)
        
        let btnWidth : CGFloat = 64
        upBtn.frame = CGRect(x: width * 0.5 - 30 - btnWidth, y: 30, width: btnWidth, height: btnWidth)
        
        downBtn.frame = CGRect(x: width * 0.5 + 30, y: 30, width: btnWidth, height: btnWidth)
    }
    
}

extension DetailUpDownView {
    
    @objc func clickUpAction() {
        clickUpBlock?()
    }
    
    @objc func clickDownAction() {
        clickDownBlock?()
    }
    
}

