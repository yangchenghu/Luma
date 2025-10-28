
import UIKit

extension UIScreen {
    
    @objc public
    static var isX: Bool {
        var isiPhoneX = false
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.delegate?.window ?? nil,
               window.safeAreaInsets.bottom > 0.0 {
                isiPhoneX = true
            }
        }
        return isiPhoneX
    }
    
    /// 屏幕宽
    @objc
    public static var width: CGFloat { UIScreen.main.bounds.width }
    
    /// 屏幕高
    @objc
    public static var height: CGFloat { UIScreen.main.bounds.height }
    
    /// 状态栏高
    @objc
    public static let statusBarHeight: CGFloat = UIScreen.isX ? 44 : 20
    
    /// 导航条高度
    @objc
    public static let navBarHeight: CGFloat = 44.0
    
    /// 导航条以上高度
    @objc
    public static let topHeight: CGFloat = statusBarHeight + navBarHeight
    
    /// tabbar 高度
    @objc
    public static let tabbarHeight: CGFloat = UIScreen.isX ? 83.0 : 49.0
    
    /// 下方安全距离
    @objc
    public static let bottomSafeHeight: CGFloat = UIScreen.isX ? 34 : 0

    /// 通用内容左边距
    @objc
    public static let contentLeft: CGFloat = 16
    
    /// 通用分割线高度
    @objc
    public static let lineHeight: CGFloat = 0.47
}
