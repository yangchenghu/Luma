//
//  CreationCardView.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/14.
//

import UIKit
import Foundation
import SDWebImage



class CreationCardView : UIView {
    
    var creation: CreationInfo?
    
    var index : Int = 0
    let imageView : CuttingImageView = CuttingImageView()
    let player : LoopPlayer = LoopPlayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.masksToBounds = true
        layer.cornerRadius = 8
        
        addSubview(imageView)
        imageView.addSubview(player)
        
        imageView.imageFrameChangedBlock = { [weak self] rect in
            self?.player.frame = rect
            debugPrint("player frame is:\(rect)")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI () {
        imageView.frame = self.bounds
        
        if let creation = creation, creation.type != .txt2Video, imageView.imageView.frame.width != 0 {
            player.frame = imageView.imageView.frame
        }
        else {
            player.frame = self.bounds
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }
    
    
    func bind(creation : CreationInfo, downloadImageFinish:(()-> Void)? = nil, startPlayBlock: (()-> Void)? = nil) {
        self.creation = creation
        
        player.frame = bounds
        
        if creation.type != .txt2Video {
            imageView.imageView.sd_setImage(with: URL(string: creation.startImgUrl), placeholderImage: nil) {[weak self] img, err, _, url in
                self?.imageView.image = img
                downloadImageFinish?()
            }
        }
        
        if let url = URL(string: creation.videoUrl) {
            player.playUrl(url: url, needCache: startPlayBlock != nil, downloadFinishBlock: startPlayBlock)
        }
    }
}
