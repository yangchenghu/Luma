
import UIKit
import Foundation


/// 实例对象扩展
public extension UIViewController {
    /// 判断是否为顶部vc
    func isTop() -> Bool {
        let vc = UIViewController.topVC()
        return vc == self
    }
    /// dismiss到根控制器
    func dismissToRoot(animated: Bool, completion: (() -> Void)? = nil) {
        var vc = self
        while let presenting = vc.presentingViewController {
            vc = presenting
        }
        vc.dismiss(animated: animated, completion: completion)
    }
    
    // 当前页面是否可以手势返回，记得页面消失的时候恢复一下。
    func canDragBack(can : Bool ) {
        UIApplication.shared.isIdleTimerDisabled = !can
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = can;
    }
}

public extension UIViewController {
    /// 顶部vc
    static
    func topVC() -> UIViewController? {
        let root = UIApplication.shared.delegate?.window??.rootViewController
        if let vc = topViewController(root: root) {
            return vc
        }
        return root
    }
}

extension UIViewController {
    private static func topViewController(root: UIViewController?) -> UIViewController? {
        if let tabbar = root as? UITabBarController {
            return topViewController(root: tabbar.selectedViewController)
        }
        if let nav = root as? UINavigationController {
            return topViewController(root: nav.visibleViewController)
        }
        if let presented = root?.presentedViewController {
            return topViewController(root: presented)
        }
        var topVC = root
        root?.children.forEach({ vc in
            let frame = vc.view.convert(vc.view.bounds, to: vc.view.window)
            if frame != .zero, frame.minX >= 0, frame.minX < UIScreen.main.bounds.width {
                topVC = vc
            }
        })
        return topVC
    }
    
    private static func getTopNavOrTabbarVC(root: UIViewController?) -> UIViewController? {
        var vc = root
        while let presented = vc?.presentedViewController {
            vc = presented
        }
        return vc
    }
}
