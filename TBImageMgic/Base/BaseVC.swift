

import Foundation
import UIKit

class BaseVC: UIViewController {
    /// 是否显示nav header
    var showHeaderView = true
    /// 是否显示返回按钮
    var showCloseView = true
    /// 是否显示 标题
    var showNavTitle = false
    /// 是否有高斯模糊
    var showHeaderBlur : Bool = false
    
    var isModal = false
    
    var showBgImage : Bool = false
    
    lazy var backgraoundImageView : UIImageView = {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.image = UIImage(named: "ic_base_bg")
        return imageView
    }()
    
    var statusBarHidden = false {
        didSet {
            guard statusBarHidden != oldValue else {
                return
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }    
    
    var blurView : UIVisualEffectView?
    
    // MARK: - lazy
    lazy var navHeaderView: UIView = {
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.topHeight))
        headView.backgroundColor = .clear
        return headView
    }()
    
    lazy var navTitleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 75, y: UIScreen.statusBarHeight, width: UIScreen.width - 150, height: UIScreen.navBarHeight))
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    lazy var navBackBtn: UIButton = {
        let btn = UIButton(type: .custom)
        /// 图片大小31，实际大小9
        btn.frame = CGRect(x: 4.5, y: UIScreen.statusBarHeight, width: 44, height: 44)
        let image = UIImage(named: "nav_back_icon_white")
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(clickBackBtn), for: .touchUpInside)
        return btn
    }()
    
    lazy var navCloseBtn: UIButton = {
        let btn = UIButton(type: .custom)
        /// 图片大小31，实际大小17
        btn.frame = CGRect(x: 4.5, y: UIScreen.statusBarHeight, width: 44, height: 44)
        let image = UIImage(named: "nav_close_icon")
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(clickCloseBtn), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - override
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        base_addObservers()
    }
    
    deinit {
        base_removeObservers()
        debugPrint("deinit -----  \(self)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if modalPresentationStyle != .overFullScreen {
            view.backgroundColor = .clear
        }
        
        if showBgImage {
            view.addSubview(backgraoundImageView)
        }

        if showHeaderView {
            navHeaderView.backgroundColor = .clear
            view.addSubview(navHeaderView)
            
            if showHeaderBlur {
                let blur = UIBlurEffect(style: .dark)
                let effectView = UIVisualEffectView(effect: blur)
                effectView.frame = navHeaderView.bounds
                navHeaderView.addSubview(effectView)
                blurView = effectView
            }
            
            if showNavTitle {
                navHeaderView.addSubview(navTitleLabel)
            }
            if showCloseView {
                if isModal {
                    navHeaderView.addSubview(navCloseBtn)
                } else {
                    navHeaderView.addSubview(navBackBtn)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if showHeaderView {
            view.bringSubviewToFront(navHeaderView)
        }
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if viewControllerToPresent.presentingViewController == nil {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    // MARK: - event
    @objc func clickBackBtn() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func clickCloseBtn() {
        dismiss(animated: true, completion: nil)
    }
    
    func base_dismissAction() {
        if isModal {
            clickCloseBtn()
        } else {
            clickBackBtn()
        }
    }
    
    public func changeBlurAlpha(alpha : CGFloat) {
        guard showHeaderBlur else { return }
        
        if alpha < 0 {
            blurView?.alpha = 0
        }
        else if alpha >= 1 {
            blurView?.alpha = 1
        }
        else {
            blurView?.alpha = alpha
        }
    }
    
    func base_addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(base_appWillResignActivity), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(base_appDidBecomeActivity), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(base_languageChanged), name: kLanguageChangedNotification, object: nil)
    }
    
    func base_removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: kLanguageChangedNotification, object: nil)
    }
    
    @objc func base_appWillResignActivity() {
        
    }
    
    @objc func base_appDidBecomeActivity() {
        
    }
    
    
    @objc func base_languageChanged() {
        
        
    }
    
}

