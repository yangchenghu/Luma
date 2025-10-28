
import Foundation
import UIKit

class AlertHelper {
    static func show(title: String?,
                     content: String,
                     confirmTitle: String?,
                     cancelTitle: String?,
                     confirmBlock: (() -> Void)?,
                     cancelBlock: (() -> Void)? = nil,
                     parent: UIViewController? = UIViewController.topVC(),
                     backDismiss : Bool = false,
                     backDismissBlock : (() -> Void)? = nil
    ) {
        
        let alert = AlertVC()
        alert.titleInfo = title
        alert.contentInfo = content
        if let doneTitle = confirmTitle {
            alert.doneText = doneTitle
        }
        if let cancelText = cancelTitle {
            alert.cancelText = cancelText
        }
        else {
            alert.hasCancel = false
        }
        
        alert.cancelAction = cancelBlock
        alert.doneAction = confirmBlock
        alert.clickBackDismiss = backDismiss
        alert.backDismissBlock = backDismissBlock
        parent?.present(alert, animated: false, completion: nil)
    }
    
    static func show(title: String?,
                     content: String,
                     confirmTitle: String?,
                     confirmBlock: (() -> Void)?,
                     parent: UIViewController? = UIViewController.topVC(),
                     backDismiss : Bool = false,
                     backDismissBlock : (() -> Void)? = nil
    ) {
        show(title: title, content: content, confirmTitle: confirmTitle, cancelTitle: nil, confirmBlock: confirmBlock, cancelBlock: nil, backDismiss: backDismiss, backDismissBlock: backDismissBlock)
    }
}
