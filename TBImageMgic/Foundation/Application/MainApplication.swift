
import Foundation
import UIKit
import SDWebImage
import SDWebImageWebPCoder

enum AppLaunchType: String {
case icon, push, url
}

private let kAppLaunchCountCacheKey = "kAppLaunchCountCacheKey"
class MainApplication {
    static let shared = MainApplication()
    
    var isNetConnect : Bool = false
    var hasRequestIdfa : Bool = false
    
    /// 三方sdk初始化完成
    private var isLaunchSdk = false
    
    private var didEnterBackground = false
    private var activeDate = Date()
    private var enterBackgroundDate = Date()
    
    deinit {
        removeObservers()
    }
    
    init() {
        addObservers()
    }
    
    /// app window 加载前配置
    func setUpBeforeWindow(options: [UIApplication.LaunchOptionsKey: Any]?) {
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }
    
    /// 初始化需要同意隐私政策之后的sdk
    func setUpDependencePrivateProtocolSDK() {
        isLaunchSdk = true
        configNetwork()

    }

    /// app window 加载后配置
    func setUpAfterWindow(options: [UIApplication.LaunchOptionsKey: Any]?) {
        configThirdLib()
        appBecomeActive()
        PayManager.shared.afterLaunch()
        
        Reporter.shared.start()
//        Thread.after(seconds: 3) {
//            Reporter.shared.requestIdfa()
//        }
    }
}

// MARK: Observers
extension MainApplication {
    /// app become active
    public func appBecomeActive() {
        
        if didEnterBackground {
        }
        didEnterBackground = false
        activeDate = Date()
    }
    
    public func appDidEnterBackground() {
        didEnterBackground = true
        enterBackgroundDate = Date()
    }
}

// MARK: config
extension MainApplication {
    
    // 配置网络
    private func configNetwork() {
        debugPrint("---configNetwork")        
        // 构建基础参数
        NetworkConfig.shared.buildBaseParams()
        //
        NetworkMonitor.shared.start()
    }
    
    private func configThirdLib() {
        setUpImage()
    }
    
    // 配置图片相关
    private func setUpImage() {
        debugPrint("---setUpImage")
        /// sd配置
        SDWebImageDownloader.shared.config.downloadTimeout = 10
        SDImageCache.shared.config.maxDiskSize = 1024 * 1024 * 1024
        SDImageCache.shared.config.maxMemoryCost = 300 * 1024 * 1024
        
        
        if #available(iOS 14.0, *) {
            SDImageCodersManager.shared.addCoder(SDImageAWebPCoder.shared)
        } else {
            // Fallback on earlier versions
            let WebPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(WebPCoder)
        }
    }

}

// observers
extension MainApplication {
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(netStatusChanged), name: NetStatusChangedNotification, object: nil)
        
    }
    
    @objc func netStatusChanged(noti: Notification) {
        guard let info : [String : Any] = noti.object as? [String : Any], let netConnect : Bool = info["isConnect"] as? Bool else {
            return
        }
        
        debugPrint("[TB] net status changed")
        isNetConnect = netConnect
        
        if isNetConnect {
            AccountManager.shared.setup()
            
            if !hasRequestIdfa {
                Thread.after(seconds: 2) {
                    Reporter.shared.requestIdfa()
                }
                hasRequestIdfa = true
                debugPrint("[TB] request idfa")
            }
        }
    }
}
