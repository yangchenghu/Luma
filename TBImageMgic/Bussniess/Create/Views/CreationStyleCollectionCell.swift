//
//  CreationStyleCollectionCell.swift
//  TBImageMgic
//
//  Created by wplive on 2024/9/8.
//

import UIKit
import Foundation
import SDWebImage

class CreationStyleModel : NSObject {
    
    var video_url : String = ""
    var nameKey : String = "" // 名称
    var promopt : String = ""
    
    var videoUrl : URL? = nil

    init(videoUrl: String, nameKey: String, promopt : String) {
        self.video_url = videoUrl
        self.nameKey = nameKey
        self.promopt = promopt
        self.videoUrl = URL(string: videoUrl)
    }
}


class CreationStyleCollectionCell : UICollectionViewCell {

    let bgView : UIView = UIView()
    let imageView : LoopPlayer = LoopPlayer()
    let titleLabel : UILabel = UILabel()
    
    var model : CreationStyleModel?
    
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
    
    
    override var isSelected: Bool {
        didSet {
            updateFrame(selected: isSelected)
        }
    }
    
    func bind(model : CreationStyleModel) {
        self.model = model
        
//        if let imagePath = Bundle.main.path(forResource: model.imgName, ofType: "mp4") {
//            imageView.playFile(path: imagePath)
//        }
        
        if let url = model.videoUrl {
            imageView.playUrl(url: url)
        }
        
        titleLabel.text = localizedStr(model.nameKey)
        layoutViews()
    }
}


extension CreationStyleCollectionCell {
    
    func setupViews() {
        
        bgView.layer.cornerRadius = 15
        bgView.layer.masksToBounds = true
        bgView.layer.borderWidth = 2
        bgView.layer.borderColor = UIColor(hexString: "#6E72F6")?.cgColor
        bgView.isHidden = true
        contentView.addSubview(bgView)
        
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = Language.shared.currentLanguageTextAlign()
        contentView.addSubview(titleLabel)
    }
    
    func layoutViews() {
        
        bgView.frame = CGRect(x: 0, y: 3, width: width, height: width)
        
        imageView.frame = CGRect(x: 5, y: 8, width: width - 10, height: width - 10)
        
        let txtHeight : CGFloat = ceil(titleLabel.sizeThatFits(CGSize(width: width - 10, height: 1000)).height)
        titleLabel.frame = CGRect(x: 5, y: imageView.bottom + 8, width: width - 10, height: txtHeight)
    }
    
    func updateFrame(selected: Bool) {
        if selected {
            bgView.isHidden = false
        }
        else {
            bgView.isHidden = true
        }
    }
    
}

