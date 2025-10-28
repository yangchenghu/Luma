
import Foundation
import UIKit

extension UIButton {
    @objc public
    func leftImageStyle(leftImg : UIImage?, rightText : String, font : UIFont, textColor : UIColor, space : Int, state : State) -> Void {
        
        self.setImage(leftImg, for: state)
        self.setTitle(rightText, for: state)
        self.setTitleColor(textColor, for: state)
        
        self.titleLabel?.font = font
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -CGFloat(space))
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat(space)/2)
    }
    
    @objc public
    func rightImageStyle(rightImg : UIImage?, leftText : String, font : UIFont, textColor : UIColor, space : Int, state : State) -> Void {
        
        self.setTitle(leftText, for: state)
        self.setImage(rightImg, for: state)
        self.setTitleColor(textColor, for: state)
        
        self.titleLabel?.font = font
        
        let imgSize : CGSize = self.imageView?.frame.size ?? CGSize(width: 0, height: 0)
        let textSize : CGSize = leftText.size(withAttributes: [NSAttributedString.Key.font : font]) ?? CGSize(width: 0, height: 0)
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imgSize.width * 2), bottom: 0, right: 0)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -(textSize.width * 2 + CGFloat(space)))
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat(space)/2)
    }
    
    @objc public
    func topImageStyle(topImg : UIImage?, bottomText : String, font : UIFont, textColor : UIColor, space : Int, state : State) -> Void {
        
        self.setImage(topImg, for: state)
        self.setTitle(bottomText, for: state)
        self.setTitleColor(textColor, for: state)
        self.titleLabel?.font = font
        
        let imgSize : CGSize = self.imageView?.frame.size ?? CGSize(width: 0, height: 0)
        let textSize : CGSize = bottomText.size(withAttributes: [NSAttributedString.Key.font : font]) ?? CGSize(width: 0, height: 0)
        
        self.contentHorizontalAlignment = .center
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imgSize.width, bottom: -(imgSize.height + CGFloat(space)), right: 0)
        
        self.imageEdgeInsets = UIEdgeInsets(top: -(textSize.height + CGFloat(space)), left: 0, bottom: 0, right:  -textSize.width)
        
        let edgeOffset : CGFloat = fabs(textSize.height - imgSize.height) / 2.0;

        self.contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0, bottom: edgeOffset, right: 0)
    }
}
