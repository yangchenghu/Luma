//  NormalRefreshApngHeader.swift
//

import Foundation
import MJRefresh
import SDWebImage

class NormalRefreshApngHeader: MJRefreshStateHeader {
    var infoText: String = "" {
        didSet {
            titleLabel.text = infoText
        }
    }

    typealias RefreshBlock = () -> Void
    var willTriggerRefreshBlock: RefreshBlock?
    
    var titleLabel = UILabel(frame:.zero)
    var animationView =  SDAnimatedImageView(frame: .zero)

    func setAnimationImage(_ image: SDAnimatedImage) {
        animationView.image = image
    }

    func setAnimationImage(name: String, ofType: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: ofType) else {
            return
        }
        animationView.image = SDAnimatedImage(contentsOfFile: path)
    }

    override var state: MJRefreshState {
        didSet {
            if state == .pulling {
                animationView.startAnimating()
                willTriggerRefreshBlock?()
                infoText = "下拉刷新"
            } else if state == .refreshing {
                animationView.startAnimating()
                infoText = "加载中..."
            } else if state == .idle {
                infoText = "下拉刷新"
                if animationView.player?.isPlaying ?? false {
                    animationView.stopAnimating()
                }
            }
        }
    }

    override var pullingPercent: CGFloat {
        willSet {
            super.pullingPercent = newValue
        }

        didSet {
            let scale = pullingPercent > 1 ? 1 : pullingPercent
            if scale > 0 {
                animationView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }

            if state == .idle && pullingPercent > 0 && pullingPercent < 0.1 && animationView.currentFrameIndex > 0 {
                animationView.player?.seekToFrame(at: 0, loopCount: 0)
                animationView.stopAnimating()
            }
        }
    }

    override func placeSubviews() {
        super.placeSubviews()
        if titleLabel.isHidden {
            animationView.frame = CGRect(x:(UIScreen.width - 24) / 2.0, y: 20, width: 24, height: 24);
        } else {
            animationView.frame = CGRect(x:(UIScreen.width - 82) / 2.0, y: 20, width: 24, height: 24);
        }
        titleLabel.frame = CGRect(x: animationView.frame.maxX + 6, y: 20, width: 100, height: 24)
    }

    override func prepare() {
        super.prepare()
        mj_h = 64
        animationView.frame = CGRect(x:(UIScreen.width - 100) / 2.0, y: 20, width: 24, height: 24);
        animationView.contentMode = .scaleAspectFit
        animationView.autoPlayAnimatedImage = false
        animationView.clearBufferWhenStopped = true
        animationView.resetFrameIndexWhenStopped = true
        addSubview(animationView)

        titleLabel.frame = CGRect(x: animationView.frame.maxX + 6, y: 20, width: 70, height: 24)
        addSubview(titleLabel)
        titleLabel.text = infoText
        titleLabel.font = .systemFont(ofSize: 11)
        titleLabel.textColor = .gray
        addSubview(titleLabel)

        stateLabel?.isHidden = true
        lastUpdatedTimeLabel?.isHidden  = true
    }
    
}
