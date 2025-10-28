//
//  LoopPlayer.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/14.
//

import UIKit
import Foundation
import AVFoundation
import CachingPlayerItem

class LoopPlayer : UIView {
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var playingUrl : URL?
    
    var beforeEnterBackgroundIsPlaying : Bool = false
    
    var startPlayBlock : ( ()-> Void )?
    
    deinit {
        stop()
        removeObservers()
        debugPrint("[player] deinit -- player")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playFile(path : String) {
        guard FileManager.default.fileExists(atPath: path) else {
            debugPrint("file is not exist")
            return
        }
        
        var fileUrl : URL
        if #available(iOS 16.0, *) {
            fileUrl = URL(filePath: path)
        } else {
            fileUrl = URL(fileURLWithPath: path)
        }
        
        playUrl(url: fileUrl)
    }
    
    func playUrl(url : URL, needCache : Bool = false, downloadFinishBlock : (() -> Void)? = nil ) {
        if let player = self.player {
            if let playingUrl = playingUrl, playingUrl == url {
                player.play()
                return
            }
            
            stop()
        }
        
        let playBlock : ((URL) ->Void) = { [weak self] url in
            let player = self?.genPlayer(url: url)
            self?.player = player
            
            // 创建 AVPlayerLayer 并将其添加到视图的层中
            let playerLayer = AVPlayerLayer(player: player)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            playerLayer.frame = self?.bounds ?? .zero
            CATransaction.commit()
            playerLayer.videoGravity =  .resizeAspect //.resizeAspectFill // .resizeAspect
            self?.layer.addSublayer(playerLayer)
            
            self?.playerLayer = playerLayer
            self?.addObserver()
            
            // 播放视频
            player?.play()
            self?.backgroundColor = .clear
            
            debugPrint("play url is:\(url), layer frame is:\(playerLayer.frame)")
        }
        
        // 不是本地文件，且需要缓存的话
        if !url.isFileURL, needCache {
            ResourceLoader.shared.getItem(url: url.absoluteString, ext: "mp4") { item, error in
                if let item = item {
                    
                    var fileUrl : URL
                    if #available(iOS 16.0, *) {
                        fileUrl = URL(filePath: item.filepath)
                    } else {
                        fileUrl = URL(fileURLWithPath: item.filepath)
                    }
                    playBlock(fileUrl)
                    downloadFinishBlock?()
                }
                else {
                    playBlock(url)
                }
            }
        }
        else {
            playBlock(url)
        }
    }
    
    func replay() {
        guard let player = player else { return }
        player.play()
    }
    
    func pause() {
        guard let player = player else { return }
        player.pause()
    }
    
    func stop() {
        guard let player = player, let layer = playerLayer else { return }
        
        player.pause()
        
        player.removeObserver(self, forKeyPath: "timeControlStatus")
        
        self.player = nil
        
        layer.removeFromSuperlayer()
        self.playerLayer = nil
        
        playingUrl = nil
        removeObservers()
    }
    
    private func genPlayer(url : URL) -> AVPlayer {
        var playerItem : AVPlayerItem

        let item = ResourceLoader.shared.buildItem(url: url.absoluteString, ext: "mp4")
        
        if url.isFileURL {
            playingUrl = url
            debugPrint("[TB] player: play local file:\(url)")
            playerItem = AVPlayerItem(url: url)
        }
        else if FileManager.default.fileExists(atPath: item.filepath) {
            var fileUrl : URL
            if #available(iOS 16.0, *) {
                fileUrl = URL(filePath: item.filepath)
            } else {
                fileUrl = URL(fileURLWithPath: item.filepath)
            }
            playingUrl = fileUrl
            playerItem = AVPlayerItem(url: fileUrl)
            debugPrint("[TB] player: play cache file:\(fileUrl)")
        }
        else {
            playingUrl = url
            playerItem = CachingPlayerItem(url: url, customFileExtension: "mp4")
            debugPrint("[TB] player: play online url:\(url)")
        }
        
        let player = AVPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = false
        // 设置静音
        player.isMuted = true
        
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.new], context: nil)
        
        return player
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            if player?.timeControlStatus == .playing {
//                debugPrint("[player] Player has started playing, rate:\(player?.rate)")
                backgroundColor = .black
                startPlayBlock?()
            } 
            else if player?.timeControlStatus == .paused {
//                debugPrint("[player] Player is paused")
            }
        }
    }
    
}

// Observer
extension LoopPlayer {
    
    func removeObservers() {
        // 移除通知监听器
        NotificationCenter.default.removeObserver(self)
    }
    
    func addObserver() {
//        guard let player = player else {
//            return
//        }
        
        // 添加通知监听器
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(noti:)), name: AVPlayerItem.didPlayToEndTimeNotification, object: nil)
        
        // 应用进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // 应用进入后台
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    
    @objc func playerDidFinishPlaying(noti : Notification) {
        // 通知过来的player跟自己的player是一个才处理
        guard let player = player else {
            return
        }
        
        let currentTime = player.currentTime()
        guard let totalTime = player.currentItem?.duration, CMTimeCompare(currentTime, totalTime) == 0 else {
            return
        }
    
//        debugPrint("current time is:\(currentTime)")
        
        // 视频播放完毕后重置播放时间并重新播放
        player.seek(to: CMTime.zero)
        player.play()
        
        // 播放过一次后，开始下载
        if let playUrl = playingUrl, !playUrl.isFileURL {
            debugPrint("[TB] player: play finish start cache")
            let url = playUrl.absoluteString
            ResourceLoader.shared.getItem(url: url, ext: "mp4") { _, _ in
                debugPrint("[TB] player: cache finish")
                
            }
        }
    }
    
    
    @objc func appWillEnterForeground() {
        guard let player else {
            return
        }
        
        guard let playingUrl else {
            return
        }
        
        if beforeEnterBackgroundIsPlaying {
            player.play()
            debugPrint("[TB] enter foreground replay player")
        }
    }
    
    @objc func appDidEnterBackground() {
        guard let player else {
            beforeEnterBackgroundIsPlaying = false
            return
        }
        
        guard let playingUrl else {
            beforeEnterBackgroundIsPlaying = false
            return
        }
        
        player.pause()
        beforeEnterBackgroundIsPlaying = true
        debugPrint("[TB] enter background stop player")
    }
    
    
    
}

// UI
extension LoopPlayer {
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
    func layoutViews() {
        guard let layer = playerLayer else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.frame = self.bounds
        CATransaction.commit()
    }
}


