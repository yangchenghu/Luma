//
//  AssetsInfo.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/12.
//

import Foundation

class AssetsInfo : NSObject {
    var userName : String = ""
    var coinCnt : Int = 0
    var consumeCoins : Int = 11
    
    var txt2VideoCoins : Int = 5
    var img2VideoCoins : Int = 8
    
    
    var coin5s : Int = 8
    var coinHigh5s : Int = 32
    
    var coin10s : Int = 16
    var coinHigh10s : Int = 64
    
    
    override init() {
        
    }
    
    init(info : [String : Any]) {
        userName = info.stringValueForKey("name")
        coinCnt = info.intValueForKey("coin_cnt")
        consumeCoins = info.intValueForKey("per_creation_coin_cnt")
        txt2VideoCoins = info.intValueForKey("per_creation_coin_cnt_text2video")
        img2VideoCoins = info.intValueForKey("per_creation_coin_cnt_image2video")
    }
    
    func update(info : [String : Any]) {
        if let name = info.stringForKey("name"), name.count > 0 {
            userName = name
        }
        
        if let coin = info.intForKey("coin_cnt"), coin >= 0 {
            coinCnt = coin
        }
        
        if let consume = info.intForKey("per_creation_coin_cnt"), consume > 0 {
            consumeCoins = consume
        }
        
        if let coins = info.intForKey("per_creation_coin_cnt_text2video"), coins > 0 {
            txt2VideoCoins = coins
        }
        
        if let coins = info.intForKey("per_creation_coin_cnt_image2video"), coins > 0 {
            img2VideoCoins = coins
        }
        
        
        if let mapInfo = info.dictForKey("per_creation_coin_map"), let coinsInfo = mapInfo.dictForKey("image2video") {
            if let c5s = coinsInfo.intForKey("mode_normal_dur_5"), c5s > 0 {
                coin5s = c5s
            }
            
            if let ch5s = coinsInfo.intForKey("mode_high_dur_5"), ch5s > 0 {
                coinHigh5s = ch5s
            }
            
            if let c10s = coinsInfo.intForKey("mode_normal_dur_10"), c10s > 0 {
                coin10s = c10s
            }
            
            if let ch10s = coinsInfo.intForKey("mode_high_dur_10"), ch10s > 0 {
                coinHigh10s = ch10s
            }
        }
    }
}
