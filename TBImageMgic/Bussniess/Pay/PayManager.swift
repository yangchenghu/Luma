//
//  PayManager.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/12.
//

import Foundation
import SwiftyStoreKit

class PayManager {
    static let shared = PayManager()
    
    var productsList : [ProductInfo] = []
    
    init() {
        
    }
    
    func afterLaunch() {
        SwiftyStoreKit.completeTransactions(atomically: false) { [weak self] (purchases) in
            guard let strongSelf = self else {return}
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                    
                case .purchased,.restored:
                    print("已完成订单")
                    //处理订单交易
//                    handleTransaction(transaction: purchase.transaction) { bool,<#arg#>  in }
                    self?.handleTransaction(transaction: purchase.transaction, checkReceiptBlock: { recp, callbak in
                        debugPrint("---!!!!!!! recp is:\(recp)")
                        
//                        callbak?
                    }, completeHandle: { result, msg in
                        
                    })
                case .failed,.purchasing,.deferred:
                    break
                @unknown default:
                    debugPrint("")
                }
            }
                                            }
    }
    
    
    func canPay() -> Bool {
        return SwiftyStoreKit.canMakePayments
    }
    
    func pay(purchaseProductId:String, checkReceiptBlock : @escaping ((String, @escaping (Bool)-> Void) -> Void) , completeHandle : @escaping (Bool, String) -> Void) {
        
        guard SwiftyStoreKit.canMakePayments else {
            debugPrint("您的手机没有打开程序内付费购买")
            completeHandle(false, "can not pay")
            return
        }
        
        debugPrint("pay for :\(purchaseProductId)")
        SwiftyStoreKit.purchaseProduct(purchaseProductId, quantity: 1, atomically: false) { purchaseResult in
            switch purchaseResult {
            case .success(let purchase):
                //处理交易
                self.handleTransaction(transaction: purchase.transaction, checkReceiptBlock: checkReceiptBlock) { result, msg in
                    completeHandle(result, msg)
                }
                
            case .error(let error):
                switch error.code {
                case .unknown:
                    debugPrint("Unknown error. Please contact support")
                    completeHandle(false, "Unknown error. Please contact support")
                    
                case .clientInvalid:
                    debugPrint("Not allowed to make the payment")
                    completeHandle(false, "Not allowed to make the payment")
                    
                case .paymentCancelled:
                    debugPrint("payment cancelled")
                    completeHandle(false, "payment cancelled")
                    
                case .paymentInvalid:
                    debugPrint("The purchase identifier was invalid")
                    completeHandle(false, "The purchase identifier was invalid")
                    
                case .paymentNotAllowed:
                    debugPrint("The device is not allowed to make the payment")
                    completeHandle(false, "The device is not allowed to make the payment")
                    
                case .storeProductNotAvailable:
                    debugPrint("The product is not available in the current storefront")
                    completeHandle(false, "The product is not available in the current storefront")
                    
                case .cloudServicePermissionDenied:
                    debugPrint("Access to cloud service information is not allowed")
                    completeHandle(false, "Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed:
                    debugPrint("Could not connect to the network")
                    completeHandle(false, "Could not connect to the network")
                    
                case .cloudServiceRevoked:
                    debugPrint("User has revoked permission to use this cloud service")
                    completeHandle(false, "User has revoked permission to use this cloud service")
                    
                default :
                    debugPrint("其他错误")
                    completeHandle(false, "Other error")
                }
//                completeHandle(false, "Unknow")
            }
        }
    }
    
    //2.处理交易
    func handleTransaction(transaction: PaymentTransaction, checkReceiptBlock : @escaping ((String, @escaping (Bool)-> Void) -> Void), completeHandle: @escaping ((Bool, String) -> Void)) {
        
        //获取receipt
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                
                print("获取校验字符串Fetch receipt success:\n\(encryptedReceipt)")
                
                //3.服务端校验
                checkReceiptBlock(encryptedReceipt) { result in
                    if result {
                        SwiftyStoreKit.finishTransaction(transaction)
                        completeHandle(true, "")
                    }
                    else {
                        completeHandle(false, "server error")
                    }
                }
            case .error(let error):
                debugPrint(" --- Fetch receipt failed: \(error)")
                completeHandle(false, error.localizedDescription)
            }
        }
    }

}
