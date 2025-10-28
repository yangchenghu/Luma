//
//  LumaUserModel.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import Foundation

// 用户订阅信息模型
class LumaSubscribeModel: NSObject {
    var id: String?
    var amount: Double = 0.0
    var type: String?
    var coins: Int = 0
    var iosProductId: String?
    var androidProductId: String?
    var expires: String?

    override init() {
        super.init()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        id = json.stringForKey("id")
        amount = json.doubleForKey("amount") ?? 0.0
        type = json.stringForKey("type")
        coins = json.intValueForKey("coins") ?? 0
        iosProductId = json.stringForKey("ios_product_id")
        androidProductId = json.stringForKey("android_product_id")
        expires = json.stringForKey("expires")
    }

    // 检查订阅是否有效
    var isValid: Bool {
        guard let expiresString = expires else { return false }
        let formatter = ISO8601DateFormatter()
        guard let expiryDate = formatter.date(from: expiresString) else { return false }
        return expiryDate > Date()
    }

    // 获取过期日期
    var expiryDate: Date? {
        guard let expiresString = expires else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: expiresString)
    }

    // 获取商品ID
    func getProductId() -> String? {
        #if os(iOS)
        return iosProductId
        #else
        return androidProductId
        #endif
    }
}

// 用户信息模型
class LumaUserModel: NSObject {
    var id: String?
    var token: String?
    var points: Int = 0
    var email: String?
    var nick: String?
    var username: String?
    var chatGroup: String?
    var subscribe: LumaSubscribeModel?

    // 用户资产信息
    var userName: String = ""
    var coinCnt: Int = 0
    var consumeCoins: Int = 11
    var txt2VideoCoins: Int = 5
    var img2VideoCoins: Int = 8
    var coin5s: Int = 8
    var coinHigh5s: Int = 32
    var coin10s: Int = 16
    var coinHigh10s: Int = 64

    override init() {
        super.init()
        subscribe = LumaSubscribeModel()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        id = json.stringForKey("id")
        token = json.stringForKey("token")
        points = json.intValueForKey("points") ?? 0
        email = json.stringForKey("email")
        nick = json.stringForKey("nick")
        username = json.stringForKey("username")
        chatGroup = json.stringForKey("chatGroup")

        if let subscribeData = json["subscribe"] as? [String: Any] {
            subscribe = LumaSubscribeModel(json: subscribeData)
        }

        // 更新资产信息
        userName = json.stringForKey("name") ?? nick ?? username ?? ""
        coinCnt = json.intValueForKey("coin_cnt") ?? points
        consumeCoins = json.intValueForKey("per_creation_coin_cnt") ?? 11
        txt2VideoCoins = json.intValueForKey("per_creation_coin_cnt_text2video") ?? 5
        img2VideoCoins = json.intValueForKey("per_creation_coin_cnt_image2video") ?? 8

        // 更新时长相关的金币消耗
        if let coinMap = json["per_creation_coin_map"] as? [String: Any],
           let img2VideoMap = coinMap["image2video"] as? [String: Any] {
            coin5s = img2VideoMap.intValueForKey("mode_normal_dur_5") ?? 8
            coinHigh5s = img2VideoMap.intValueForKey("mode_high_dur_5") ?? 32
            coin10s = img2VideoMap.intValueForKey("mode_normal_dur_10") ?? 16
            coinHigh10s = img2VideoMap.intValueForKey("mode_high_dur_10") ?? 64
        }
    }

    // 检查用户是否已登录
    var isLoggedIn: Bool {
        return token?.isEmpty == false
    }

    // 获取显示名称
    var displayName: String {
        return nick ?? username ?? userName ?? "User"
    }
}

// MARK: - Dictionary Extension for Safe Parsing

extension Dictionary where Key == String, Value == Any {
    func stringForKey(_ key: String) -> String? {
        return self[key] as? String
    }

    func intValueForKey(_ key: String) -> Int? {
        if let value = self[key] as? Int {
            return value
        } else if let stringValue = self[key] as? String {
            return Int(stringValue)
        } else if let doubleValue = self[key] as? Double {
            return Int(doubleValue)
        }
        return nil
    }

    func doubleForKey(_ key: String) -> Double? {
        if let value = self[key] as? Double {
            return value
        } else if let stringValue = self[key] as? String {
            return Double(stringValue)
        } else if let intValue = self[key] as? Int {
            return Double(intValue)
        }
        return nil
    }

    func boolForKey(_ key: String) -> Bool? {
        return self[key] as? Bool
    }

    func dictForKey(_ key: String) -> [String: Any]? {
        return self[key] as? [String: Any]
    }

    func arrayForKey<T>(_ key: String) -> [T]? {
        return self[key] as? [T]
    }
}