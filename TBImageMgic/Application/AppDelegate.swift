

import UIKit
import FBSDKCoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var tabbarVC: TabbarViewController?
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        MainApplication.shared.setUpBeforeWindow(options: launchOptions)
        if setUpWindow() {
            MainApplication.shared.setUpAfterWindow(options: launchOptions)
        }

        return true
    }
    
    private func setUpWindow() -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        
        UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .dark
        } else {
            // Fallback on earlier versions
        }
        
        MainApplication.shared.setUpDependencePrivateProtocolSDK()
        window?.makeKeyAndVisible()
        configTabbar()
//        configHomePage()
        return true
    }
    
    private func configTabbar () {
        let tabbar = TabbarViewController()
        tabbarVC = tabbar
        let nav = BaseNavigationViewController(rootViewController: tabbar)
        window?.rootViewController = nav
    }
    
    private func configHomePage() {
        let vc = HomeViewController()
        let nav = BaseNavigationViewController(rootViewController: vc)
        window?.rootViewController = nav
    }
        
    func applicationWillResignActive(_ application: UIApplication) {

    }
    
    static var bgTask: UIBackgroundTaskIdentifier = .invalid
    
    func endBgTask(_ application: UIApplication) {
        Thread.doInMainThread {
            if Self.bgTask != .invalid {
                application.endBackgroundTask(Self.bgTask)
                Self.bgTask = .invalid
            }
        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        endBgTask(application)
        Self.bgTask = application.beginBackgroundTask {
            self.endBgTask(application)
        }
        Thread.after(seconds: 15) {
            self.endBgTask(application)
        }
        
        MainApplication.shared.appDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        endBgTask(application)
        MainApplication.shared.appBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
//        PaymentService.shared.removeTransactionObserver()
//        PushService.shared.close()
    }
    
    /// deeplink
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        MainApplication.shared.application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        MainApplication.shared.application(application, handleOpen: url)
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        MainApplication.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    /// Universal Link
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        MainApplication.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if #available(iOS 16, *) {
            return [.portrait, .landscapeRight]
        } else {
            return .portrait
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let deviceTokenString = deviceToken.reduce("",{$0 + String(format:"%02x",$1)})
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // 撤销通知
        if #available(iOS 10.0, *), let removeMessageId = userInfo["removeMessageId"] as? String {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [removeMessageId])
        }
        completionHandler(.newData)
    }
}

