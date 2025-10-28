//
//  CreationInfoViewModel.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/21.
//

import UIKit
import Foundation


class CreationInfoViewModel : NSObject {
    var creation : CreationInfo?
    var width : CGFloat = UIScreen.width
    
    var imgSize : CGSize = CGSizeZero
    var itemSize : CGSize = CGSizeZero
    
    var nameFrame : CGRect = CGRectZero
    var timeFrame : CGRect = CGRectZero
    
    var timeString : String = ""
    var userName : String = ""
    
    var text : String = ""
    
    func bind(creation : CreationInfo) {
        self.creation = creation
        
        timeString = englishReadableTime(creation.createTime)
        userName = creation.userName
    }
    
    func rebuildTime() {
        guard let creation = self.creation else {
            return
        }
        timeString = englishReadableTime(creation.createTime)
    }
    
    
    func buildHomePageModel() {
        guard let creation = self.creation else {
            return
        }
        
        width = floor( (UIScreen.width - 16 * 3) * 0.5)
        let imgHeight : CGFloat = floor(width * 1.35)
        imgSize = CGSize(width: width, height: imgHeight)
        
        itemSize = CGSize(width: width, height: imgHeight + 46)
        
        nameFrame = CGRect(x: 0, y: imgHeight + 8, width: width, height: 18)
        timeFrame = CGRect(x: 0, y: imgHeight + 30, width: width, height: 18)
    }
    
    func buildLibraryPageModel() {
        guard let creation = self.creation else {
            return
        }
        
        width = floor( (UIScreen.width - 16 * 3) * 0.5)
        let imgHeight : CGFloat = floor(width * 1.35)
        imgSize = CGSize(width: width, height: imgHeight)
        itemSize = CGSize(width: width, height: imgHeight + 24)
        timeFrame = CGRect(x: 0, y: imgHeight + 8, width: width, height: 16)
    }
    
    func buildGroupPageModel() {
        guard let creation = self.creation else {
            return
        }
        width = UIScreen.width
        timeString = readableTime2(creation.createTime)
        text = creation.text
    }
    
    func englishReadableTime(_ time: Int64) -> String {
        let thatDate = Date(timeIntervalSince1970: TimeInterval(time))
        let formate = DateFormatter()
        formate.locale = Locale(identifier: Language.shared.currentLanguage())
        formate.dateFormat = "HH:mm MMM dd"
        return formate.string(from: thatDate)
    }
    
    func readableTime2(_ time: Int64) -> String {
        let thatDate = Date(timeIntervalSince1970: TimeInterval(time))
        let formate = DateFormatter()
        formate.locale = Locale(identifier: Language.shared.currentLanguage())
        formate.dateFormat = "HH:mm MMM dd, yyyy"
        return formate.string(from: thatDate)
    }
    
}
