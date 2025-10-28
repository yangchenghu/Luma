//
//  LumaOrderModel.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import Foundation

// 支付包模型
class LumaPaymentPackageModel: NSObject {
    var id: String?
    var name: String?
    var amount: Double = 0.0
    var coins: Int = 0
    var iosProductId: String?
    var androidProductId: String?
    var description: String?
    var isPopular: Bool = false
    var isRecommended: Bool = false

    override init() {
        super.init()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        id = json.stringForKey("id")
        name = json.stringForKey("name")
        amount = json.doubleForKey("amount") ?? 0.0
        coins = json.intValueForKey("coins") ?? 0
        iosProductId = json.stringForKey("ios_product_id")
        androidProductId = json.stringForKey("android_product_id")
        description = json.stringForKey("description")
        isPopular = json.boolForKey("isPopular") ?? false
        isRecommended = json.boolForKey("isRecommended") ?? false
    }

    // 获取商品ID
    func getProductId() -> String? {
        #if os(iOS)
        return iosProductId
        #else
        return androidProductId
        #endif
    }

    // 获取显示价格
    func getDisplayPrice() -> String {
        return String(format: "¥%.2f", amount)
    }

    // 获取描述
    func getDisplayDescription() -> String {
        return description ?? "\(coins) 金币"
    }
}

// 订单模型
class LumaOrderModel: NSObject {
    var id: String?
    var orderId: String?
    var packageId: String?
    var userId: String?
    var amount: Double = 0.0
    var status: String?
    var transactionId: String?
    var paymentMethod: String?
    var createdAt: Date?
    var updatedAt: Date?
    var completedAt: Date?

    override init() {
        super.init()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        id = json.stringForKey("id")
        orderId = json.stringForKey("orderId")
        packageId = json.stringForKey("packageId")
        userId = json.stringForKey("userId")
        amount = json.doubleForKey("amount") ?? 0.0
        status = json.stringForKey("status")
        transactionId = json.stringForKey("transactionId")
        paymentMethod = json.stringForKey("paymentMethod")

        // 解析时间戳
        if let timestamp = json.doubleForKey("createdAt") {
            createdAt = Date(timeIntervalSince1970: timestamp)
        }
        if let timestamp = json.doubleForKey("updatedAt") {
            updatedAt = Date(timeIntervalSince1970: timestamp)
        }
        if let timestamp = json.doubleForKey("completedAt") {
            completedAt = Date(timeIntervalSince1970: timestamp)
        }
    }

    // 订单状态
    var isCompleted: Bool {
        return status == "completed"
    }

    var isPending: Bool {
        return status == "pending"
    }

    var isProcessing: Bool {
        return status == "processing"
    }

    var isFailed: Bool {
        return status == "failed"
    }

    var isCancelled: Bool {
        return status == "cancelled"
    }

    // 获取状态显示文本
    var statusText: String {
        switch status {
        case "completed":
            return "已完成"
        case "pending":
            return "待支付"
        case "processing":
            return "处理中"
        case "failed":
            return "失败"
        case "cancelled":
            return "已取消"
        default:
            return "未知"
        }
    }

    // 获取显示价格
    func getDisplayPrice() -> String {
        return String(format: "¥%.2f", amount)
    }
}