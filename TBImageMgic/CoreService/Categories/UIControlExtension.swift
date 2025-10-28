
import Foundation
import UIKit

private var kUIControlClickBlockKey = "kUIControlClickBlockKey"

extension UIControl {
    public var clickBlock: (() -> Void)? {
        get {
            if let objc = objc_getAssociatedObject(self, &kUIControlClickBlockKey) as? UIViewAssociatedObj {
                return objc.block
            }
            return nil
        }
        set {
            if let value = newValue {
                if let obj = objc_getAssociatedObject(self, &kUIControlClickBlockKey) as? UIViewAssociatedObj {
                    obj.block = value
                } else {
                    let obj = UIViewAssociatedObj(block: value)
                    self.addTarget(obj, action: #selector(obj.fun), for: .touchUpInside)
                    objc_setAssociatedObject(self, &kUIControlClickBlockKey, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            } else {
                if let obj = objc_getAssociatedObject(self, &kUIControlClickBlockKey) as? UIViewAssociatedObj {
                    self.removeTarget(obj, action: #selector(obj.fun), for: .touchUpInside)
                    objc_setAssociatedObject(self, &kUIControlClickBlockKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }
        }
    }
    
}
