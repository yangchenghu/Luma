//
//  LumaTaskModel.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import Foundation

class LumaTaskModel: NSObject {
    /// 任务ID
    var id: String?

    /// 任务状态
    var status: String?

    /// 文件名
    var filename: String?

    /// 文件URL
    var url: String?

    /// 缩略图URL
    var thumbnailUrl: String?

    /// 模板ID
    var templateId: String?

    /// 进程ID（用于进度查询）
    var processId: String?

    /// 视频ID（用于进度查询）
    var videoId: String?

    /// 预计任务耗时（秒），默认20秒
    var taskDuration: Int = 20

    /// 任务创建时间
    var createdAt: Date?

    /// 任务更新时间
    var updatedAt: Date?

    override init() {
        super.init()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        id = json.stringForKey("_id")
        status = json.stringForKey("status")
        filename = json.stringForKey("filename")
        url = json.stringForKey("url")
        thumbnailUrl = json.stringForKey("thumbnailUrl")
        templateId = json.stringForKey("templateId")
        processId = json.stringForKey("processId")
        videoId = json.stringForKey("videoId")
        taskDuration = json.intValueForKey("taskDuration") ?? 20

        // 解析时间戳
        if let timestamp = json.doubleForKey("createdAt") {
            createdAt = Date(timeIntervalSince1970: timestamp)
        }
        if let timestamp = json.doubleForKey("updatedAt") {
            updatedAt = Date(timeIntervalSince1970: timestamp)
        }
    }

    /// 是否已完成
    var isCompleted: Bool {
        return status == "completed"
    }

    /// 是否待处理
    var isPending: Bool {
        return status == "pending"
    }

    /// 是否处理中
    var isProcessing: Bool {
        return status == "processing"
    }

    /// 是否失败
    var isFailed: Bool {
        return status == "failed"
    }

    /// 是否有有效的视频URL
    var hasValidVideoUrl: Bool {
        guard let url = url else { return false }
        return !url.isEmpty && url.hasPrefix("http")
    }

    /// 是否有有效的缩略图URL
    var hasValidThumbnailUrl: Bool {
        guard let thumbnailUrl = thumbnailUrl else { return false }
        return !thumbnailUrl.isEmpty
    }

    /// 是否可以查询进度（需要 processId 和 videoId）
    var canCheckProgress: Bool {
        guard let processId = processId, let videoId = videoId else { return false }
        return !processId.isEmpty && !videoId.isEmpty
    }

    /// 获取状态显示文本
    var statusText: String {
        switch status {
        case "completed":
            return "已完成"
        case "pending":
            return "等待中"
        case "processing":
            return "处理中"
        case "failed":
            return "失败"
        default:
            return "未知"
        }
    }

    /// 获取用于显示的URL（优先返回缩略图）
    var displayUrl: String {
        return thumbnailUrl ?? url ?? ""
    }
}

// 任务历史数据模型
class LumaTaskHistoryModel: NSObject {
    var tasks: [LumaTaskModel] = []
    var hasMore: Bool = false
    var page: Int = 1
    var total: Int = 0

    override init() {
        super.init()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        // 解析任务列表
        if let taskArray = json.arrayForKey("list") as? [[String: Any]] {
            tasks = taskArray.map { LumaTaskModel(json: $0) }
        }

        // 解析分页信息
        hasMore = json.boolForKey("hasMore") ?? false
        page = json.intValueForKey("page") ?? 1
        total = json.intValueForKey("total") ?? 0
    }

    func appendTasks(from json: [String: Any]) {
        if let taskArray = json.arrayForKey("list") as? [[String: Any]] {
            let newTasks = taskArray.map { LumaTaskModel(json: $0) }
            tasks.append(contentsOf: newTasks)
        }

        hasMore = json.boolForKey("hasMore") ?? false
        page = json.intValueForKey("page") ?? 1
        total = json.intValueForKey("total") ?? 0
    }
}

// MARK: - Task Progress Model

class TaskProgressModel: NSObject {
    var status: String?
    var progress: Double = 0.0
    var message: String?
    var error: String?

    override init() {
        super.init()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        status = json.stringForKey("status")
        progress = json.doubleForKey("progress") ?? 0.0
        message = json.stringForKey("message")
        error = json.stringForKey("error")
    }

    var isCompleted: Bool {
        return status == "completed"
    }

    var isFailed: Bool {
        return status == "failed"
    }

    var progressPercentage: Int {
        return Int(progress * 100)
    }
}