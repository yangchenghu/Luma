//
//  ProductInfo.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/12.
//

import Foundation

class ProductInfo : NSObject {
    var imgUrl : String = ""  // 背景图片地址
    var coinUrl : String = "" // 金币图片链接
    var text : String = ""    //
    var usdCnt : Int = 0      // 美元金额 699 -> $6.99
    var coinCnt : Int = 0     // 金币数量（总数）
    var coinBaseCnt : Int = 0    // 金币数量，基础
    var coinExtCnt : Int = 0     // 金币数量，额外
    
    var productId : Int64 = 0       // 商品ID
    var iosProductId : String = ""  // 苹果商品id
    
    var coinDiscount : Int = 0   // 折扣
    
    init(info : [String : Any]) {
        imgUrl = info.stringValueForKey("img_url")
        coinUrl = info.stringValueForKey("coin_url")
        
        text = info.stringValueForKey("text")
        coinCnt = info.intValueForKey("coin_cnt")
        coinBaseCnt = info.intValueForKey("coin_cnt_base")
        coinExtCnt = info.intValueForKey("coin_cnt_extra")
        
        usdCnt = info.intValueForKey("usd_cnt")
        
        productId = info.int64ValueForKey("product_id")
        iosProductId = info.stringValueForKey("ios_product_id")
        
        if 0 != coinCnt {
            coinDiscount = Int( round( 100 * ( Float(coinExtCnt) / Float(coinCnt))) )
        }
        
//        debugPrint("[tb] product coindiscount is:\(coinDiscount)")
    }
}
