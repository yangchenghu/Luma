//
//  OrderInfo.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/12.
//

import Foundation


class OrderInfo : NSObject {
    enum OrderStatus : Int {
        case inProgress = 10 // 待充值
        case finished = 20
    }
    
    
    var coinCnt : Int = 0  // 兑换的金币数量
    var usdCnt : Int = 0   // 需要花费多少美金，699 = $6.99
    var orderId : Int64 = 0
    var productId : Int64 = 0  // 商品id
    var status : OrderStatus = .inProgress
    
    init(info : [String : Any]) {
        coinCnt = info.intValueForKey("coin_cnt")
        usdCnt = info.intValueForKey("usd_cnt")
        orderId = info.int64ValueForKey("order_id")
        productId = info.int64ValueForKey("product_id")
        let iStatus = info.intValueForKey("status")
        status = OrderStatus(rawValue: iStatus) ?? .inProgress
    }
    
    
    
    
}

