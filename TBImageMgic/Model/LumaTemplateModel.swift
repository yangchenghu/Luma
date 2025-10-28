//
//  LumaTemplateModel.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import Foundation

class LumaTemplateModel: NSObject {
    var id: String?
    var level: String? // 模板级别
    var categoryId: String?
    var templateId: String?
    var name: String?
    var videoUrl: String?
    var thumbnailUrl: String?
    var gifUrl: String?
    var i18nJson: String?
    var templateMode: String? // 模板模式：single 或 double
    var modelFrame: String? // 模型框架：wan2 等

    // 本地化数据缓存
    private var i18nData: [String: Any]?

    override init() {
        super.init()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        id = json.stringForKey("_id")
        level = json.stringForKey("env")
        categoryId = json.stringForKey("categoryId")
        templateId = json.stringForKey("templateId")
        name = json.stringForKey("name")
        videoUrl = json.stringForKey("videoUrl")
        thumbnailUrl = json.stringForKey("thumbnailUrl")
        gifUrl = json.stringForKey("gifUrl")
        i18nJson = json.stringForKey("i18n_json")
        templateMode = json.stringForKey("templateMode")
        modelFrame = json.stringForKey("modelFrame")

        // 解析国际化数据
        if let i18nJsonString = i18nJson {
            parseI18nData(i18nJsonString)
        }
    }

    /// 获取图片地址，优先返回 gifUrl，如果没有则返回 thumbnailUrl
    var imageUrl: String {
        return gifUrl ?? thumbnailUrl ?? ""
    }

    /// 根据当前系统语言获取本地化名称
    var localizedName: String {
        // 如果没有国际化数据，返回原始name
        if i18nData == nil {
            return name ?? ""
        }

        // 获取当前语言码
        let currentLanguageCode = getCurrentLanguageCode()

        // 尝试获取当前语言的名称
        if let languageData = i18nData?[currentLanguageCode] as? [String: Any],
           let localizedName = languageData["name"] as? String {
            return localizedName
        }

        // 如果当前语言没有对应翻译，回退到英文
        if let englishData = i18nData?["en"] as? [String: Any],
           let englishName = englishData["name"] as? String {
            return englishName
        }

        // 如果都没有，返回原始name
        return name ?? ""
    }

    /// 解析国际化数据
    private func parseI18nData(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return }

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                i18nData = json
            }
        } catch {
            print("Failed to parse i18n JSON: \(error)")
        }
    }

    /// 获取当前语言码
    private func getCurrentLanguageCode() -> String {
        let preferredLanguages = Locale.preferredLanguages

        for language in preferredLanguages {
            // 获取语言码 (如 "en", "zh-Hans")
            let components = language.components(separatedBy: "-")
            if let languageCode = components.first {
                return languageCode
            }
        }

        return "en" // 默认返回英文
    }

    /// 是否需要两张图片（根据模板模式）
    var requiresTwoImages: Bool {
        return templateMode == "double"
    }
}

// 模板列表数据模型
class LumaTemplateListModel: NSObject {
    var templates: [LumaTemplateModel] = []
    var hasMore: Bool = false
    var page: Int = 1

    override init() {
        super.init()
    }

    init(json: [String: Any]) {
        super.init()
        update(with: json)
    }

    func update(with json: [String: Any]) {
        // 解析模板列表
        if let templateArray = json.arrayForKey("list") as? [[String: Any]] {
            templates = templateArray.map { LumaTemplateModel(json: $0) }
        }

        // 解析分页信息
        hasMore = json.boolForKey("hasMore") ?? false
        page = json.intValueForKey("page") ?? 1
    }

    func appendTemplates(from json: [String: Any]) {
        if let templateArray = json.arrayForKey("list") as? [[String: Any]] {
            let newTemplates = templateArray.map { LumaTemplateModel(json: $0) }
            templates.append(contentsOf: newTemplates)
        }

        hasMore = json.boolForKey("hasMore") ?? false
        page = json.intValueForKey("page") ?? 1
    }
}