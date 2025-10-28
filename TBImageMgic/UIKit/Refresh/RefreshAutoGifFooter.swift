//  RefreshAutoGifFooter.swift
//  PPWidgets
//
//  Created by supermanmwng on 2021/9/17.
//

import Foundation
import MJRefresh
import SDWebImage

public class RefreshAutoGifFooter: MJRefreshAutoStateFooter {
    
    var noMoreText: String = "- 底 -" {
        didSet {
            setTitle(noMoreText, for: .noMoreData)
        }
    }
    
    var animationView =  SDAnimatedImageView(frame: .zero)

    func setAnimationImage(name: String) {
        animationView.image = SDAnimatedImage(named: name)
    }
    
    public override func prepare() {
        super.prepare()
        animationView.frame = CGRect(x:(UIScreen.width - 60) / 2.0, y: 8, width: 60, height: 60);
        animationView.contentMode = .scaleAspectFit
        animationView.autoPlayAnimatedImage = false
        animationView.clearBufferWhenStopped = true
        animationView.resetFrameIndexWhenStopped = true
        animationView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        addSubview(animationView)
        
        setAnimationImage(name: "left_right_refresh.webp")
        isAutomaticallyRefresh = true
        triggerAutomaticallyRefreshPercent = 0.6
        autoTriggerTimes = 1
        isRefreshingTitleHidden = true
        stateLabel?.font = .systemFont(ofSize: 13)
        stateLabel?.textColor = .gray
        setTitle("", for: .idle)
        setTitle("", for: .refreshing)
        setTitle("", for: .noMoreData)
    }
    
    public override func placeSubviews() {
        super .placeSubviews()
        animationView.frame = CGRect(x: (bounds.width - 16) / 2, y: (bounds.height - 16 ) / 2, width: 16, height: 16)
    }
    
    public override var state: MJRefreshState {
        didSet {
            animationView.isHidden = false
            if state == .refreshing {
                animationView.startAnimating()
            } else if state == .noMoreData || state == .idle {
                animationView.stopAnimating()
                animationView.isHidden = true
            }
        }
    }
}
