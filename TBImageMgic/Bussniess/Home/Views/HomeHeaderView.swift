//
//  HomeHeaderView.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/20.
//

import UIKit
import Foundation

class HomeHeaderView : BaseView {
    
    let player : LoopPlayer = LoopPlayer()

    let titleLabel : UILabel = UILabel()
    let detailLabel : UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        view_languageChanged()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        relayViews()
    }
    
    override func view_languageChanged() {
        titleLabel.textAlignment = Language.shared.currentLanguageTextAlign()
        titleLabel.text = localizedStr("Interactive Scenes")
        
        detailLabel.textAlignment = Language.shared.currentLanguageTextAlign()
        detailLabel.text = localizedStr("Capture with LumaVideo and View IN lifelike, interactive")
    }
    
}

extension HomeHeaderView {
    
    func setupViews() {
        player.frame = bounds
        addSubview(player)
        if let filepath = Bundle.main.path(forResource: "main_video_v2", ofType: "mp4") {
            player.playFile(path: filepath)
        }
        
        var top : CGFloat = height - 217
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: top, width: width, height: 217)
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        gradientLayer.colors = [
            UIColor(red: 0.043, green: 0.043, blue: 0.043, alpha: 0).cgColor,
            UIColor(red: 0.047, green: 0.035, blue: 0.094, alpha: 0.71).cgColor,
            UIColor(red: 0.047, green: 0.035, blue: 0.094, alpha: 0.94).cgColor,
            UIColor(red: 0.043, green: 0.016, blue: 0.078, alpha: 1).cgColor
          ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.locations = [0, 0.467736, 0.623914, 0.71762]
        
        layer.addSublayer(gradientLayer)
        
        top += 121
        
        let imageView = UIImageView(frame: CGRect(x: 20, y: top, width: 28, height: 28))
        imageView.image = UIImage(named: "home_header_icon_star")
        addSubview(imageView)
        
        titleLabel.frame = CGRect(x: 54, y: top, width: 300, height: 28)
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textColor = .white
        titleLabel.text = localizedStr("Interactive Scenes")
        addSubview(titleLabel)
        
        top += 34
        detailLabel.frame = CGRect(x: 20, y: top, width: UIScreen.width - 40, height: 66)
        detailLabel.font = .systemFont(ofSize: 16)
        detailLabel.textColor = .white.withAlphaComponent(0.64)
        detailLabel.numberOfLines = 0
        detailLabel.text = localizedStr("Capture with LumaVideo and View IN lifelike, interactive")
        addSubview(detailLabel)
    }
    
    func relayViews() {
        
    }
}

