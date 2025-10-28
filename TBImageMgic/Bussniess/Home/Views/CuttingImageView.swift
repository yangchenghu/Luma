//
//  CuttingImageView.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/14.
//

import UIKit
import Foundation

class CuttingImageView : UIView {
    
    var image : UIImage? {
        set {
            imageView.image = newValue
            setupUI()
        }
        get {
            imageView.image
        }
    }
    
    let iconView : UIImageView = UIImageView()
    let imageView : UIImageView = UIImageView()
    var imageFrameChangedBlock : ((CGRect)-> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        
        iconView.image = UIImage(named: "icon_placeholder_pic")
        addSubview(iconView)
        addSubview(imageView)
        
        backgroundColor = UIColor(hexString: "#161A28")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        iconView.frame = CGRect(x: (width - 84) * 0.5, y: (height - 84) * 0.5, width: 84, height: 84)

        guard let img = imageView.image else { return }
        guard self.width != 0 && self.height != 0 else { return }
        
        iconView.frame = CGRectZero
        
        let imgWidth : CGFloat = img.size.width
        let imgHeight : CGFloat = img.size.height
        
        guard imgWidth != 0 && imgHeight != 0 else {
            imageView.frame = bounds
            return
        }
        
        let viewScale : CGFloat = self.width / self.height
        let imgScale : CGFloat = imgWidth / imgHeight

        if imgScale < viewScale {
            let imgViewHeight : CGFloat = ceil(imgHeight * self.width / imgWidth)
            imageView.frame = CGRect(x: 0, y: (self.height - imgViewHeight) * 0.5, width: self.width, height: imgViewHeight)
//            debugPrint("cutting-1, frame is:\(imageView.frame)")
        }
        else if imgScale > viewScale {
            let imgViewWidth : CGFloat = ceil(imgWidth * self.height / imgHeight)
            imageView.frame = CGRect(x: (self.width - imgViewWidth) * 0.5, y: 0, width: imgViewWidth, height: self.height)
//            debugPrint("cutting-2, frame is:\(imageView.frame)")
        }
        else {
            imageView.frame = self.bounds
        }
        
        imageFrameChangedBlock?(imageView.frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }
    
    
    
    
}





