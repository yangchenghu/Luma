//
//  HomeViewCollectionViewCell.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/21.
//

import UIKit
import Foundation
import SDWebImage

class HomeViewCollectionViewCell : UICollectionViewCell {
    var creationVM : CreationInfoViewModel?
    let imageView : CuttingImageView = CuttingImageView()
    
    let animationView : LOTAnimationView = LOTAnimationView()
    let failImageView : UIImageView = UIImageView()
    
    let makingMaskView : UIView = UIView()
    let player : LoopPlayer = LoopPlayer()
    let nameLabel : UILabel = UILabel()
    let timeLabel : UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(creation : CreationInfoViewModel) {
        self.creationVM = creation
        
        imageView.frame = CGRect(x: 0, y: 0, width: creation.imgSize.width, height: creation.imgSize.height)
        player.frame = imageView.bounds
        
        nameLabel.frame = creation.nameFrame
        nameLabel.text = "@" + creation.userName
        
        timeLabel.frame = creation.timeFrame
        timeLabel.text = creation.timeString
        
        guard let creation = creation.creation else { return }
        
        let url = creation.startImgUrl
        sd_cancelCurrentImageLoad()
        // 有图片地址，加载图片
        if url.count > 0 {
            imageView.imageView.sd_setImage(with: URL(string: url), placeholderImage: nil) {[weak self] image, e, _, _ in
                self?.imageView.image = image
            }
        }
        
        let vurl : String = creation.videoUrl
//        if creation.status == .finish,
        
        player.isHidden = true
        if creation.status == .inProgress {
            player.pause()
//            player.isHidden = true
            makingMaskView.frame = imageView.bounds
            makingMaskView.isHidden = false
            failImageView.frame = CGRectZero
            animationView.frame = CGRect(x: ceil( (makingMaskView.width - 50) * 0.5 ), y: ceil( (makingMaskView.height - 50) * 0.5 ), width: 50, height: 50)
            if let path = Bundle.main.path(forResource: "creation_library_general", ofType: "json") {
                animationView.filePath = (light : path, dark : nil)
                animationView.play()
            }
        }
        else if creation.status == .fail {
            player.pause()
//            player.isHidden = true
            makingMaskView.frame = imageView.bounds
            animationView.frame = CGRectZero
            failImageView.frame = CGRect(x: ceil( (makingMaskView.width - 50) * 0.5 ), y: ceil( (makingMaskView.height - 50) * 0.5 ), width: 50, height: 50)
            makingMaskView.isHidden = false
        }
//        else if !ResourceLoader.shared.hasCacheUrl(url: vurl, ext: "mp4") {
//            debugPrint("[cell] play loading")
//            // 没有缓存，显示加载动画
//            makingMaskView.frame = imageView.bounds
//            makingMaskView.isHidden = false
//            failImageView.frame = CGRectZero
//            animationView.frame = CGRect(x: ceil( (makingMaskView.width - 50) * 0.5 ), y: ceil( (makingMaskView.height - 50) * 0.5 ), width: 50, height: 50)
//            if let path = Bundle.main.path(forResource: "video_loading", ofType: "json") {
//                animationView.filePath = (light : path, dark : nil)
//                animationView.play()
//            }
//            
//            if let url = URL(string: vurl) {
//                player.playUrl(url: url, needCache: true) { [weak self] in
//                    self?.player.isHidden = false
//                    self?.makingMaskView.isHidden = true
//                    self?.animationView.stop()
//                    debugPrint("[cell] play remove animation")
//                }
//            }
//        }
        else {
//            player.isHidden = true
            makingMaskView.isHidden = true
            animationView.stop()
            if let url = URL(string: vurl) {
                player.playUrl(url: url)
            }
        }
    }
}

extension HomeViewCollectionViewCell {
    func setupViews() {
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        
        player.startPlayBlock = { [weak self] in
            guard let c = self?.creationVM?.creation, c.status == .finish else { return }
            self?.player.isHidden = false
        }
        
        imageView.addSubview(player)
        
        makingMaskView.frame = imageView.bounds
        makingMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        animationView.loopAnimationCount = -1
        makingMaskView.addSubview(animationView)
        
        failImageView.image = UIImage(named: "icon_library_status_fail")
        makingMaskView.addSubview(failImageView)
        
        imageView.addSubview(makingMaskView)
        makingMaskView.isHidden = true
        
        imageView.imageFrameChangedBlock = { [weak self] rect in
            self?.player.frame = rect
        }
        
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .white.withAlphaComponent(0.64)
        addSubview(nameLabel)
        
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .white.withAlphaComponent(0.64)
        addSubview(timeLabel)
    }
    
    
    
    
}

