//
//  LumaImageModel.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import Foundation
import UIKit

class LumaImageModel: NSObject {
    /// 图片ID
    var id: Int = 0

    /// 图片URL
    var imageUrl: String?

    /// 文件名
    var filename: String?

    /// 文件路径
    var path: String?

    /// 原始URL
    var originalUrl: String?

    /// 本地图片路径
    var localImagePath: String?

    /// 图片大小（字节）
    var fileSize: Int = 0

    /// 图片尺寸
    var imageSize: CGSize = .zero

    /// 图片格式
    var imageFormat: String?

    override init() {
        super.init()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        id = json.intValueForKey("id") ?? 0
        imageUrl = json.stringForKey("imageUrl")
        filename = json.stringForKey("filename")
        path = json.stringForKey("path")
        originalUrl = json.stringForKey("originalUrl")
    }

    convenience init(localPath: String, image: UIImage) {
        self.init()
        self.localImagePath = localPath
        self.imageSize = image.size
        self.filename = (localPath as NSString).lastPathComponent

        // 获取文件大小
        if let fileURL = URL(string: localPath) {
            do {
                let resources = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                self.fileSize = resources.fileSize ?? 0
            } catch {
                print("Failed to get file size: \(error)")
            }
        }

        // 检测图片格式
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            self.imageFormat = "jpeg"
        } else if let imageData = image.pngData() {
            self.imageFormat = "png"
        }
    }

    /// 获取有效的图片URL（优先本地路径）
    var validImageUrl: String? {
        if let localPath = localImagePath, !localPath.isEmpty {
            return localPath
        }
        return imageUrl
    }

    /// 是否有本地图片
    var hasLocalImage: Bool {
        return localImagePath?.isEmpty == false
    }

    /// 是否已上传到服务器
    var isUploaded: Bool {
        return imageUrl?.isEmpty == false
    }

    /// 图片显示尺寸（适合显示的尺寸）
    var displaySize: CGSize {
        guard imageSize.width > 0 && imageSize.height > 0 else {
            return CGSize(width: 100, height: 100)
        }

        let maxWidth: CGFloat = 300
        let maxHeight: CGFloat = 400

        let widthRatio = maxWidth / imageSize.width
        let heightRatio = maxHeight / imageSize.height
        let ratio = min(widthRatio, heightRatio)

        return CGSize(
            width: imageSize.width * ratio,
            height: imageSize.height * ratio
        )
    }

    /// 格式化文件大小
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .KB, .MB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }
}

// 上传令牌模型
class UploadTokenModel: NSObject {
    var token: String?
    var uploadUrl: String?
    var expiration: Date?

    override init() {
        super.init()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        token = json.stringForKey("token")
        uploadUrl = json.stringForKey("uploadUrl")

        if let expiresAt = json.doubleForKey("expiration") {
            expiration = Date(timeIntervalSince1970: expiresAt)
        }
    }

    /// 令牌是否有效
    var isValid: Bool {
        guard let expirationDate = expiration else { return false }
        return expirationDate > Date()
    }
}