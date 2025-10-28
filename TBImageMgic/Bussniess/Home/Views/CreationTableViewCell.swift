//
//  CreationTableViewCell.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/14.
//

import UIKit
import Foundation
import SDWebImage

class CreationTableViewCell : UITableViewCell {
    
    var creation : CreationInfo?
    
    var coverView : CuttingImageView = CuttingImageView()
    var makingMaskView : UIView = UIView()
    var timeLabel = UILabel()
    var coinLabel = UILabel()
    
    var player : LoopPlayer?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
        
        let left : CGFloat = 20.0
        var top : CGFloat = 20.0
        let right : CGFloat = 20;
        let imgWidth : CGFloat = UIScreen.width - left - right
        
        coverView.frame = CGRect(x: left, y: top, width: imgWidth, height: imgWidth)
        coverView.layer.cornerRadius = 20
        coverView.layer.masksToBounds = true
        coverView.layer.borderWidth = 0.5
        coverView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        
        contentView.addSubview(coverView)
        
        makingMaskView.frame = coverView.bounds
        makingMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let icon : UIImageView = UIImageView()
        icon.image = UIImage(named: "icon_history_generating")
        icon.frame = CGRect(x: (imgWidth - 32) * 0.5, y: imgWidth * 0.5 - 32, width: 32, height: 32)
        makingMaskView.addSubview(icon)
        let label = UILabel(frame: CGRect(x: 30, y: icon.bottom + 8, width: (imgWidth - 30 - 30), height: 22))
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.text = localizedStr("生成中") + "..."
        makingMaskView.addSubview(label)

        coverView.addSubview(makingMaskView)
        makingMaskView.isHidden = true

        top += imgWidth
        top += 12
        
        timeLabel.frame = CGRect(x: left, y: top, width: 200, height: 22)
        timeLabel.textColor = .white
        timeLabel.font = .boldSystemFont(ofSize: 17)
        contentView.addSubview(timeLabel)
        
        coinLabel.frame = CGRect(x: UIScreen.width - right - 200, y: top, width: 200, height: 22)
        coinLabel.textColor = .white
        coinLabel.textAlignment = .right
        coinLabel.font = .boldSystemFont(ofSize: 17)
        contentView.addSubview(coinLabel)

        coverView.imageFrameChangedBlock = { [weak self] rect in
            self?.player?.frame = rect
            debugPrint("player frame is:\(rect)")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(creation : CreationInfo) {
        self.creation = creation
        
        let time = creation.createString
        timeLabel.text = time
        
        let coin = creation.coinCnt
        coinLabel.text = "-\(coin)"
        
        let imgUrl = creation.startImgUrl
        
        sd_cancelCurrentImageLoad()
        if imgUrl.count > 0 {
            coverView.imageView.sd_setImage(with: URL(string: imgUrl), placeholderImage: nil) { [weak self] img, error, _, url in
                if let loadImgUrl = url?.absoluteString, loadImgUrl == imgUrl {
                    self?.coverView.image = img
//                    if let player = self?.player, let frame = self?.coverView.imageView.bounds {
//                        player.frame = frame
//                    }
                    
                }
            }
        }
        
        if creation.status == .inProgress {
            makingMaskView.isHidden = false
        }
        else {
            makingMaskView.isHidden = true
            playVideo()
        }
    }
    
    func playVideo() {
        guard let creation = creation, creation.status == .finish else {
            return
        }
//        debugPrint("creat id :\(creation.creationId) is playing" )
        if let player = player, let url = URL(string: creation.videoUrl) {
            player.isHidden = false
            player.playUrl(url: url)
        }
        else {
            let player = LoopPlayer(frame: coverView.imageView.frame)
            coverView.addSubview(player)
            self.player = player
            if let url = URL(string: creation.videoUrl) {
                player.playUrl(url: url)
            }
        }
    }
    
    func pause() {
        player?.pause()
        debugPrint("creat id :\(creation?.creationId) is pause" )
        if let player = player {
            player.pause()
            player.isHidden = true
        }
    }
    
}

