//
//  UploadTokenModel.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import Foundation

class UploadTokenModel: NSObject {
    var accessKeyId: String?
    var accessKeySecret: String?
    var securityToken: String?
    var bucket: String?
    var region: String?
    var endpoint: String?
    var expiration: Date?
    var callbackUrl: String?
    var callbackBody: String?
    var callbackBodyType: String?
    var policy: String?
    var signature: String?

    // 阿里云STS临时凭证
    var ossAccessKeyId: String?
    var ossAccessKeySecret: String?
    var ossSecurityToken: String?

    // 上传限制
    var maxSize: Int = 0 // 最大文件大小（字节）
    var allowedTypes: [String] = [] // 允许的文件类型

    override init() {
        super.init()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        accessKeyId = json.stringForKey("AccessKeyId")
        accessKeySecret = json.stringForKey("AccessKeySecret")
        securityToken = json.stringForKey("SecurityToken")
        bucket = json.stringForKey("bucket")
        region = json.stringForKey("region")
        endpoint = json.stringForKey("endpoint")

        // 解析过期时间
        if let expirationString = json.stringForKey("Expiration") {
            let formatter = ISO8601DateFormatter()
            expiration = formatter.date(from: expirationString)
        }

        callbackUrl = json.stringForKey("callbackUrl")
        callbackBody = json.stringForKey("callbackBody")
        callbackBodyType = json.stringForKey("callbackBodyType")
        policy = json.stringForKey("policy")
        signature = json.stringForKey("signature")

        // 阿里云OSS相关
        ossAccessKeyId = json.stringForKey("OSSAccessKeyId") ?? json.stringForKey("accessKeyId")
        ossAccessKeySecret = json.stringForKey("OSSAccessKeySecret") ?? json.stringForKey("accessKeySecret")
        ossSecurityToken = json.stringForKey("OSSAccessKeySecret") ?? json.stringForKey("securityToken")

        // 上传限制
        maxSize = json.intValueForKey("maxSize") ?? 0
        if let types = json["allowedTypes"] as? [String] {
            allowedTypes = types
        }
    }

    /// 是否已过期
    var isExpired: Bool {
        guard let exp = expiration else { return true }
        return exp < Date()
    }

    /// 获取剩余有效期（秒）
    var remainingValidity: TimeInterval {
        guard let exp = expiration else { return 0 }
        return exp.timeIntervalSince(Date())
    }

    /// 是否有效（未过期）
    var isValid: Bool {
        return !isExpired && remainingValidity > 60 // 至少保留60秒缓冲
    }

    /// 获取完整的OSS endpoint URL
    var fullEndpointURL: String? {
        guard let endpoint = endpoint, let bucket = bucket else { return nil }

        if endpoint.hasPrefix("http") {
            return endpoint
        } else {
            return "https://\(bucket).\(endpoint)"
        }
    }

    /// 检查文件类型是否允许上传
    func isFileTypeAllowed(_ fileName: String) -> Bool {
        guard let fileExtension = fileName.components(separatedBy: ".").last?.lowercased() else {
            return false
        }

        if allowedTypes.isEmpty {
            return true // 如果没有限制，默认允许
        }

        return allowedTypes.contains(fileExtension)
    }

    /// 检查文件大小是否超出限制
    func isFileSizeValid(_ fileSize: Int) -> Bool {
        return maxSize <= 0 || fileSize <= maxSize
    }
}