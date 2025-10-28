

import UIKit
import Foundation

extension UIFont {
    
    
    private static func fontName(_ name: String, size: CGFloat) -> UIFont {
        if let font = UIFont(name: name, size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
}
