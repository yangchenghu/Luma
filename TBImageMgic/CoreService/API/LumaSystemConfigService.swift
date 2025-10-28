//
//  LumaSystemConfigService.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import Foundation

@objcMembers
class LumaSystemConfigService: NSObject {

    static let shared = LumaSystemConfigService()

    private var systemConfig: [String: Any]?
    private var configUpdateTime: Date?

    // MARK: - Public Methods

    /// 获取系统配置
    func getSystemConfig(completion: @escaping ([String: Any]?, Error?) -> Void) {
        NetworkCore.get(path: "api/system/config", params: nil) { (data, message) in
            if let configData = data {
                self.systemConfig = configData
                self.configUpdateTime = Date()
                completion(configData, nil)
            } else {
                completion(nil, NSError(domain: "SystemConfigService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get system config"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 获取缓存的系统配置
    func getCachedSystemConfig() -> [String: Any]? {
        // 如果配置存在且未过期（缓存时间小于1小时），返回缓存的配置
        guard let config = systemConfig,
              let updateTime = configUpdateTime,
              Date().timeIntervalSince(updateTime) < 3600 else {
            return nil
        }
        return config
    }

    /// 强制刷新系统配置
    func refreshSystemConfig(completion: @escaping ([String: Any]?, Error?) -> Void) {
        getSystemConfig(completion: completion)
    }

    /// 获取特定配置项
    func getConfigValue<T>(key: String, defaultValue: T) -> T {
        guard let config = getCachedSystemConfig(),
              let value = config[key] as? T else {
            return defaultValue
        }
        return value
    }

    /// 获取API基础URL
    func getAPIBaseURL() -> String {
        return getConfigValue(key: "apiBaseUrl", defaultValue: "https://tserver.singlow.xyz")
    }

    /// 获取图片上传配置
    func getImageUploadConfig() -> [String: Any] {
        return getConfigValue(key: "imageUpload", defaultValue: [:])
    }

    /// 获取AI服务配置
    func getAIServiceConfig() -> [String: Any] {
        return getConfigValue(key: "aiService", defaultValue: [:])
    }

    /// 获取支付配置
    func getPaymentConfig() -> [String: Any] {
        return getConfigValue(key: "payment", defaultValue: [:])
    }

    /// 获取功能开关配置
    func getFeatureFlags() -> [String: Any] {
        return getConfigValue(key: "features", defaultValue: [:])
    }

    /// 检查特定功能是否启用
    func isFeatureEnabled(featureName: String) -> Bool {
        let features = getFeatureFlags()
        return features.boolForKey(featureName) ?? false
    }
}