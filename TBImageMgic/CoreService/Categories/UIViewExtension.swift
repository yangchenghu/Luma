
import UIKit
import Foundation

// MARK: - 点击事件
private var kUIViewClickBlockKey = "kUIViewClickBlockKey"
class UIViewAssociatedObj: NSObject {
    var block: (() -> Void)
    var tapGesture: UITapGestureRecognizer?
    
    init(block: @escaping (() -> Void)) {
        self.block = block
        super.init()
    }
    
    @objc func fun() {
        block()
    }
}

public
extension UIView {
    var tapBlock: (() -> Void)? {
        get {
            if let objc = objc_getAssociatedObject(self, &kUIViewClickBlockKey) as? UIViewAssociatedObj {
                return objc.block
            }
            return nil
        }
        set {
            if let value = newValue {
                self.isUserInteractionEnabled = true
                if let obj = objc_getAssociatedObject(self, &kUIViewClickBlockKey) as? UIViewAssociatedObj {
                    obj.block = value
                } else {
                    let obj = UIViewAssociatedObj(block: value)
                    self.addGestureRecognizer(UITapGestureRecognizer(target: obj, action: #selector(obj.fun)))
                    objc_setAssociatedObject(self, &kUIViewClickBlockKey, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            } else {
                if let obj = objc_getAssociatedObject(self, &kUIViewClickBlockKey) as? UIViewAssociatedObj {
                    if let tap = obj.tapGesture {
                        self.removeGestureRecognizer(tap)
                    }
                    objc_setAssociatedObject(self, &kUIViewClickBlockKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }
        }
    }
}
