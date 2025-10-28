//
//  BannerInfo.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/12.
//

import Foundation

class BannerInfo : NSObject {
    var imgUrl : String = ""
    var btnText : String = ""
    var scheme : String = ""
    
    init(info : [String : Any]) {
        imgUrl = info.stringValueForKey("img_url")
        btnText = info.stringValueForKey("button_text")
        scheme = info.stringValueForKey("scheme")
    }
    
}
