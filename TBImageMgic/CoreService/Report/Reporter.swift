//
//  Reporter.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/13.
//

import Foundation
import Adjust
import FirebaseAnalytics
//import FirebaseCrashlyticsore

import Adjust
import AdSupport
import AppTrackingTransparency


class Reporter : NSObject {

    enum Event : String {
        case active = "active"
        case login = "login"
        case purchase = "purchase"
        case register = "register"
        case revenue = "revenue" // 需要上报金额
        case create = "ceate"
        case create_finish = "create_finish"
        
        func toAdjust() -> String {
            switch self {
            case .active:
                return "bovjt9"
            case .login:
                return "48p656"
            case .purchase:
                return "wyns31"
            case .register:
                return "hdqqgs"
            case .revenue:
                return "tsrglp"
            case .create:
                return "hg0lux"
            case .create_finish:
                return "6t49ir"
            }
        }
    }

    static let shared = Reporter()
    
    override init() {
        super.init()
        
        setupAdjust()
        setupFirebase()
        setupSkan()
        
        // 延时处理，太早弹不出来授权
//        Thread.after(seconds: 2) {
//            self.requestIdfa()
//        }
    }
    
    public func start() {
        report(event: .active)
    }
    
    
    public func report(event : Reporter.Event, params : [String : String]? = nil) {
        
        reportFirebase(event: event, params: params)
        reportAdjust(event: event, params: params)
    }
    
    
    private func reportFirebase(event : Reporter.Event,  params : [String : String]? = nil) {
            
        #if DEBUG
        
        #else
        Analytics.logEvent(event.rawValue, parameters: params)
        #endif
    }
    
    private func reportAdjust(event : Reporter.Event, params : [String : String]? = nil) {
        let adEvent = ADJEvent(eventToken: event.toAdjust())
        if let params = params {
            for (key, value) in params {
                adEvent?.addPartnerParameter(key, value: value)
                if event == .revenue, key == "usd", let count = Int(value), count > 0  {
                    adEvent?.setRevenue((CGFloat(count) / 100), currency: "USD")
                }
                
            }
        }
        debugPrint("[LV] report adjust:\(adEvent?.eventToken), params is:\(params)")
        Adjust.trackEvent(adEvent)
    }
    
    
    
    public func requestIdfa() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                case .denied:
                    debugPrint("用户拒绝")
                    break
                case .authorized:
                    debugPrint("用户允许")
                    debugPrint("IDFA:\(ASIdentifierManager.shared().advertisingIdentifier.uuidString)")
                    break
                case .notDetermined:
                    debugPrint("用户没有选择")
                default:
                    break
                }
            }
        } else {
            // iOS13及之前版本，继续用以前的方式
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                debugPrint("可以获取:\(ASIdentifierManager.shared().advertisingIdentifier.uuidString)")
            } else {
                debugPrint("用户未打开IDFA开关")
            }
        }
    }
    

    private func setupAdjust() {
        let yourAppToken = "ko5vi4dj6xhc"
        
        #if DEBUG
        let environment = ADJEnvironmentSandbox
        #else
        let environment = ADJEnvironmentProduction
        #endif
        
        let myAdjustConfig = ADJConfig(
            appToken: yourAppToken,
            environment: environment)
        #if DEBUG
        myAdjustConfig?.logLevel = ADJLogLevelDebug
        #else
        myAdjustConfig?.logLevel = ADJLogLevelError
        #endif
        
        // Your code here
        Adjust.appDidLaunch(myAdjustConfig)
    }
    
    private func setupFirebase() {
        #if DEBUG
        
        #else
        FirebaseApp.configure()
        #endif
    }
    
    
    private func setupSkan() {
//        ADJSKAdNetwork.getInstance()?.registerAppForAdNetworkAttribution()
        
    }
    
    
    
}

