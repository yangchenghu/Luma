
import Foundation
import UIKit
import SDWebImage

class ScrollViewLoadingHeader: UIView {
    enum LoadingStatus {
        case normal, beginDrag, endDrag, loading
    }
    
    private let animationView = SDAnimatedImageView()
    var status: LoadingStatus = .normal {
        didSet {
            guard status != oldValue else { return }
            switch status {
            case .normal:
                UIView.animate(withDuration: 0.2) {
                    self.animationView.center = CGPoint(x: self.bounds.width / 2.0, y: -self.animationView.frame.height / 2.0)
                } completion: { finish in
                    if self.status == .normal {
                        self.animationView.stopAnimating()
                        self.animationView.isHidden = true
                    }
                }
            case .beginDrag:
                animationView.isHidden = false
                if !animationView.isAnimating {
                    animationView.startAnimating()
                }
            case .endDrag:
                break
            case .loading:
                refreshAction?()
            }
        }
    }
    var refreshAction: (() -> Void)?
    var loadingOffset: CGFloat = 54
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        animationView.frame = CGRect(x:(UIScreen.width - 100) / 2.0, y: 20, width: 24, height: 24);
        animationView.contentMode = .scaleAspectFit
        animationView.autoPlayAnimatedImage = false
        animationView.clearBufferWhenStopped = true
        animationView.resetFrameIndexWhenStopped = true
        animationView.isHidden = true
        animationView.alpha = 0.8
        if let path = Bundle.main.path(forResource: "refresh_header", ofType: "gif") {
            animationView.image = SDAnimatedImage(contentsOfFile: path)
        }
        addSubview(animationView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animationView.center = CGPoint(x: bounds.width / 2.0, y: -animationView.frame.height / 2.0)
    }
    
    func scrollViewBeginDraging(_ scrollView: UIScrollView) {
        status = .beginDrag
    }
    
    func scrollViewEndDraging(_ scrollView: UIScrollView) {
        let offSetY = scrollView.contentOffset.y
        status = .endDrag
        if offSetY < -loadingOffset {
            status = .loading
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY = scrollView.contentOffset.y
        if status == .loading {
            if offSetY < -loadingOffset {
                animationView.center = CGPoint(x: bounds.width / 2.0, y: -animationView.frame.height / 2.0 - offSetY)
            } else {
                animationView.center = CGPoint(x: bounds.width / 2.0, y: -animationView.frame.height / 2.0 + loadingOffset)
            }
        } else if offSetY <= 0 {
            animationView.center = CGPoint(x: bounds.width / 2.0, y: -animationView.frame.height / 2.0 - offSetY)
            if status == .endDrag, offSetY < -loadingOffset {
                status = .loading
            }
        } else {
            animationView.center = CGPoint(x: bounds.width / 2.0, y: -animationView.frame.height / 2.0)
        }
    }
    
    func endRefresh() {
        status = .normal
    }
}
