
import UIKit
import Foundation

class BaseView : UIView {
    
    deinit {
        base_removeObservers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        base_addObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func view_languageChanged() {
        
    }
}

extension BaseView {
    
    func base_removeObservers() {
        NotificationCenter.default.removeObserver(self, name: kLanguageChangedNotification, object: nil)
    }
    
    func base_addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(base_languageChanged), name: kLanguageChangedNotification, object: nil)
    }
    
    @objc func base_languageChanged() {
        view_languageChanged()
    }
}

