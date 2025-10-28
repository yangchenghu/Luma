//
//  NetworkMonitor.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/30.
//

import Foundation
import Alamofire

public let NetStatusChangedNotification = NSNotification.Name(rawValue: "NetStatusChangedNotification")

// 网络监听类
public class NetworkMonitor {
    public static let shared = NetworkMonitor()
    private let reachabilityManager = NetworkReachabilityManager()
    
    public func start() {
        reachabilityManager?.startListening { status in
            var isConnect : Bool = false
            switch status {
            case .notReachable:
                print("The network is not reachable")
            case .reachable(.cellular):
                isConnect = true
                print("The network is reachable over the cellular connection")
            case .reachable(.ethernetOrWiFi):
                isConnect = true
                print("The network is reachable over the WiFi or Ethernet connection")
            case .unknown:
                print("It is unknown whether the network is reachable")
            }
            
            NotificationCenter.default.post(name: NetStatusChangedNotification, object: ["isConnect" : isConnect])
        }
    }
    
    public func stop() {
        reachabilityManager?.stopListening()
    }
}

