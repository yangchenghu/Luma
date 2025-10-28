//
//  LumaTaskService.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import Foundation
import UIKit

@objcMembers
class LumaTaskService: NSObject {

    static let shared = LumaTaskService()

    // MARK: - Public Methods

    /// 获取阿里云上传图片参数
    func getUploadToken(completion: @escaping (UploadTokenModel?, Error?) -> Void) {
        guard let userId = LumaUserService.shared.getUserId(), !userId.isEmpty else {
            completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        NetworkCore.get(path: "api/tast/pixverse/getUploadToken", params: nil) { (data, message) in
            if let tokenData = data {
                let uploadToken = UploadTokenModel(json: tokenData)
                completion(uploadToken, nil)
            } else {
                completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get upload token"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 上传图片到pix
    func uploadToPixverse(name: String, path: String, size: Int, ossUrl: String, completion: @escaping (LumaImageModel?, Error?) -> Void) {
        guard let userId = LumaUserService.shared.getUserId(), !userId.isEmpty else {
            completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        let params: [String: Any] = [
            "name": name,
            "path": path,
            "size": size,
            "ossUrl": ossUrl
        ]

        NetworkCore.post(path: "api/tast/pixverse/uploadToPix", params: params) { (data, message) in
            if let imageData = data {
                let imageModel = LumaImageModel(json: imageData)
                completion(imageModel, nil)
            } else {
                completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to upload image to Pixverse"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 上传图片（备用接口）
    func uploadImage(_ image: UIImage, progress: ((Double) -> Void)? = nil, completion: @escaping (LumaImageModel?, Error?) -> Void) {
        guard let userId = LumaUserService.shared.getUserId(), !userId.isEmpty else {
            completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        // 将图片转换为Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"]))
            return
        }

        // 这里应该使用multipart上传，但现有的NetworkCore不支持
        // 暂时使用其他方法
        completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload method not implemented"]))
    }

    /// 获取aws预签名url
    func getAWSUploadUrl(fileName: String, completion: @escaping (String?, Error?) -> Void) {
        let params: [String: Any] = [
            "fileName": fileName
        ]

        NetworkCore.get(path: "api/task/aws/getUploadUrl", params: params) { (data, message) in
            if let url = data?["url"] as? String {
                completion(url, nil)
            } else {
                completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get AWS upload URL"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 创建任务
    func createTask(templateId: String? = nil,
                    prompt: String? = nil,
                    costType: String? = nil,
                    path: String,
                    imageUrl: String,
                    originalUrl: String,
                    imageUrl2: String? = nil,
                    completion: @escaping (LumaTaskModel?, Error?) -> Void) {
        guard let userId = LumaUserService.shared.getUserId(), !userId.isEmpty else {
            completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        var params: [String: Any] = [
            "path": path,
            "imageUrl": imageUrl,
            "originalUrl": originalUrl,
            "userId": userId
        ]

        // 如果有第二张图片，添加第二张图片参数
        if let imageUrl2 = imageUrl2, !imageUrl2.isEmpty {
            params["imageUrl2"] = imageUrl2
        }

        // 如果有templateId，则使用模板模式
        if let templateId = templateId, !templateId.isEmpty {
            params["templateId"] = templateId
        } else {
            // 如果没有templateId，则使用自定义模式，需要传入prompt
            if let prompt = prompt, !prompt.isEmpty {
                params["prompt"] = prompt
            }
        }

        if let costType = costType, !costType.isEmpty {
            params["costType"] = costType
        }

        NetworkCore.post(path: "api/task/pixverse/create", params: params) { (data, message) in
            if let taskData = data {
                let task = LumaTaskModel(json: taskData)
                completion(task, nil)
            } else {
                completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to create task"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 获取任务历史记录
    func getTaskHistory(page: Int = 1, completion: @escaping (LumaTaskHistoryModel?, Error?) -> Void) {
        guard let userId = LumaUserService.shared.getUserId(), !userId.isEmpty else {
            completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        NetworkCore.post(path: "api/task/history", params: ["userId": userId, "page": page]) { (data, message) in
            if let historyData = data {
                let history = LumaTaskHistoryModel(json: historyData)
                completion(history, nil)
            } else {
                completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get task history"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 删除任务
    func deleteTask(taskId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = LumaUserService.shared.getUserId(), !userId.isEmpty else {
            completion(false, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        let params: [String: Any] = [
            "taskId": taskId,
            "userId": userId
        ]

        NetworkCore.post(path: "api/task/delete", params: params) { (data, message) in
            completion(true, nil)
        } failBlock: { error in
            completion(false, error)
        }
    }

    /// 获取任务进度
    func checkTaskProgress(processId: String, videoId: String, completion: @escaping (TaskProgressModel?, Error?) -> Void) {
        guard let userId = LumaUserService.shared.getUserId(), !userId.isEmpty else {
            completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        let params: [String: Any] = [
            "processId": processId,
            "videoId": videoId,
            "userId": userId
        ]

        NetworkCore.get(path: "api/task/pixverse/progress", params: params) { (data, message) in
            if let progressData = data {
                let progress = TaskProgressModel(json: progressData)
                completion(progress, nil)
            } else {
                completion(nil, NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to check task progress"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 轮询任务进度直到完成
    func pollTaskProgress(processId: String, videoId: String, maxAttempts: Int = 30, interval: TimeInterval = 2.0, progressUpdate: ((TaskProgressModel) -> Void)? = nil, completion: @escaping (TaskProgressModel?, Error?) -> Void) {
        var attempts = 0
        var lastProgress: TaskProgressModel?

        func checkProgress() {
            attempts += 1

            checkTaskProgress(processId: processId, videoId: videoId) { [weak self] progress, error in
                guard let self = self else { return }

                if let error = error {
                    if attempts >= maxAttempts {
                        completion(lastProgress, error)
                    } else {
                        // 继续尝试
                        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                            checkProgress()
                        }
                    }
                    return
                }

                guard let progress = progress else {
                    if attempts >= maxAttempts {
                        completion(lastProgress, nil)
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                            checkProgress()
                        }
                    }
                    return
                }

                lastProgress = progress
                progressUpdate?(progress)

                if progress.isCompleted || progress.isFailed {
                    completion(progress, nil)
                } else if attempts < maxAttempts {
                    DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                        checkProgress()
                    }
                } else {
                    completion(progress, nil)
                }
            }
        }

        checkProgress()
    }
}