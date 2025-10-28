
import Foundation
import UIKit

class TabbarItemView: BaseView {
    private class Config {
        let text: String
        let normalColor: UIColor
        let selectColor: UIColor
        let normalIcon: UIImage?
        let selectIcon: UIImage?
        
        init(text: String, ncolor: UIColor, scolor: UIColor, nicon: UIImage?, sicon: UIImage?) {
            self.text = text
            normalColor = ncolor
            selectColor = scolor
            normalIcon = nicon
            selectIcon = sicon
        }
    }
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let selectedDotLayer = CALayer()
    private let badgeDotView = UIView()
    private let bridgeLabel = UILabel()
    private var config: Config?
    
    var type : TabbarIndexType = .home
    
    // 未读数显示红点，default is false
    var unreadCountShowDot = false
    
    var badgeCount: Int = 0 {
        didSet {
            if self.unreadCountShowDot {
                bridgeLabel.isHidden = true
                badgeDotView.isHidden = badgeCount <= 0
            }
            else {
                badgeDotView.isHidden = true
                bridgeLabel.isHidden = badgeCount <= 0
                
                if badgeCount > 99 {
                    bridgeLabel.text = "99+"
                }
                else {
                    bridgeLabel.text = "\(badgeCount)"
                }
            }
            
            resetUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconView)
        titleLabel.font = .systemFont(ofSize: 10, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white.withAlphaComponent(0.25)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resetUI()
    }
    
    private func resetUI() {
        let iconWidth: CGFloat = 29
        let iconHeight : CGFloat = 24
        let top : CGFloat = 8
        iconView.frame = CGRect(x: (bounds.width - iconWidth) / 2.0, y: top, width: iconWidth, height: iconHeight)
        
        badgeDotView.frame = CGRect(x: iconView.frame.maxX - 8, y: iconView.frame.minY, width: 8, height: 8)
        
        if !(bridgeLabel.text?.isEmpty ?? true)  {
//            bridgeLabel.sizeToFit()
            let textWidth : CGFloat = ceil( bridgeLabel.sizeThatFits(CGSize(width: 1000, height: 20)).width)
            
            let bridgeWidth = max(textWidth + 12, 20)
            bridgeLabel.frame = CGRect(x: iconView.frame.maxX + 15 - bridgeWidth , y: 2, width: bridgeWidth, height: 20)
        }
        else {
            bridgeLabel.frame = .zero
        }
        
        titleLabel.frame = CGRect(x: 0, y: 34, width: frame.width, height: 14)
//        selectedDotLayer.frame = CGRect(x: titleLabel.frame.midX - 2, y: titleLabel.frame.midY - 2, width: 4, height: 4)
    }
    
    func config(text: String, normalIcon: UIImage?, normalColor: UIColor, selectIcon: UIImage?, selectColor: UIColor) {
        config = Config(text: text, ncolor: normalColor, scolor: selectColor, nicon: normalIcon, sicon: selectIcon)
        titleLabel.text = localizedStr(text)
    }
    
    var selected: Bool = false {
        didSet {
            if selected {
                iconView.image = config?.selectIcon
                titleLabel.textColor = config?.selectColor
            } else {
                iconView.image = config?.normalIcon
                titleLabel.textColor = config?.normalColor
                selectedDotLayer.isHidden = true
            }
        }
    }
    
    
    override func view_languageChanged() {
        guard let config = config else {
            return
        }   
        titleLabel.text = localizedStr(config.text)
    }
}
