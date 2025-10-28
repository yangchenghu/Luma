//
//  LumaOrderService.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import Foundation

@objcMembers
class LumaOrderService: NSObject {

    static let shared = LumaOrderService()

    // MARK: - Public Methods

    /// 获取金币消耗类型
    func getCostTypes(templateId: String? = nil, prompt: String? = nil, completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let userId = LumaUserService.shared.getUserId(), !userId.isEmpty else {
            completion(nil, NSError(domain: "OrderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        var params: [String: Any] = ["userId": userId]

        if let templateId = templateId {
            params["templateId"] = templateId
        }

        if let prompt = prompt {
            params["prompt"] = prompt
        }

        NetworkCore.get(path: "api/order/cost", params: params) { (data, message) in
            if let costData = data {
                completion(costData, nil)
            } else {
                completion(nil, NSError(domain: "OrderService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get cost types"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 获取支付配置商品
    func getPaymentPackages(completion: @escaping ([LumaPaymentPackageModel]?, Error?) -> Void) {
        NetworkCore.get(path: "api/order/packages", params: nil) { (data, message) in
            if let packageArray = data?["packages"] as? [[String: Any]] {
                let packages = packageArray.map { LumaPaymentPackageModel(json: $0) }
                completion(packages, nil)
            } else {
                completion(nil, NSError(domain: "OrderService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get payment packages"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 创建支付订单
    func createPaymentOrder(packageId: String, completion: @escaping (LumaOrderModel?, Error?) -> Void) {
        guard let userId = LumaUserService.shared.getUserId(), !userId.isEmpty else {
            completion(nil, NSError(domain: "OrderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        let params: [String: Any] = [
            "packageId": packageId,
            "userId": userId
        ]

        NetworkCore.post(path: "api/order/app/create", params: params) { (data, message) in
            if let orderData = data {
                let order = LumaOrderModel(json: orderData)
                completion(order, nil)
            } else {
                completion(nil, NSError(domain: "OrderService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to create payment order"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 轮询订单状态
    func checkOrderStatus(orderId: String, transactionId: String? = nil, completion: @escaping (String?, Error?) -> Void) {
        var params: [String: Any] = ["orderId": orderId]

        if let transactionId = transactionId {
            params["transactionId"] = transactionId
        }

        NetworkCore.get(path: "api/order/status", params: params) { (data, message) in
            if let status = data?["status"] as? String {
                completion(status, nil)
            } else {
                completion(nil, NSError(domain: "OrderService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to check order status"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 轮询订单状态直到完成
    func pollOrderStatus(orderId: String, transactionId: String? = nil, maxAttempts: Int = 30, interval: TimeInterval = 2.0, completion: @escaping (String?, Error?) -> Void) {
        var attempts = 0

        func checkStatus() {
            attempts += 1

            checkOrderStatus(orderId: orderId, transactionId: transactionId) { [weak self] status, error in
                guard let self = self else { return }

                if let error = error {
                    if attempts >= maxAttempts {
                        completion(nil, error)
                    } else {
                        // 继续尝试
                        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                            checkStatus()
                        }
                    }
                    return
                }

                guard let status = status else {
                    if attempts >= maxAttempts {
                        completion(nil, nil)
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                            checkStatus()
                        }
                    }
                    return
                }

                // 如果订单状态是最终状态，返回结果
                if status == "completed" || status == "failed" || status == "cancelled" {
                    completion(status, nil)
                } else if attempts < maxAttempts {
                    DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                        checkStatus()
                    }
                } else {
                    completion(status, nil)
                }
            }
        }

        checkStatus()
    }
}