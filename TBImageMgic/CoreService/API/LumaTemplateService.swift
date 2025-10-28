//
//  LumaTemplateService.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import Foundation
import AdSupport
import AppTrackingTransparency

@objcMembers
class LumaTemplateService: NSObject {

    static let shared = LumaTemplateService()

    // MARK: - Public Methods

    /// 获取首页模板列表
    func getHomeTemplates(page: Int = 1, completion: @escaping (LumaTemplateListModel?, Error?) -> Void) {
        var params: [String: Any] = ["page": page]

        // 添加广告标识符
        addAdvertisingIdentifiers(to: &params) { [weak self] error in
            guard let self = self, error == nil else {
                completion(nil, error)
                return
            }

            NetworkCore.get(path: "api/template/home", params: params) { (data, message) in
                if let templateData = data {
                    let templateList = LumaTemplateListModel(json: templateData)
                    completion(templateList, nil)
                } else {
                    completion(nil, NSError(domain: "TemplateService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get home templates"]))
                }
            } failBlock: { error in
                completion(nil, error)
            }
        }
    }

    /// 获取推荐模板数据
    func getAllTemplates(completion: @escaping ([LumaTemplateModel]?, Error?) -> Void) {
        NetworkCore.get(path: "api/template/list", params: nil) { (data, message) in
            if let templateArray = data?["list"] as? [[String: Any]] {
                let templates = templateArray.map { LumaTemplateModel(json: $0) }
                completion(templates, nil)
            } else {
                completion(nil, NSError(domain: "TemplateService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get all templates"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 分类下的模版
    func getTemplatesByCategory(categoryId: String?, page: Int = 1, completion: @escaping (LumaTemplateListModel?, Error?) -> Void) {
        var params: [String: Any] = [
            "page": page
        ]

        if let categoryId = categoryId {
            params["categoryId"] = categoryId
        }

        NetworkCore.get(path: "api/template/getBy", params: params) { (data, message) in
            if let templateData = data {
                let templateList = LumaTemplateListModel(json: templateData)
                completion(templateList, nil)
            } else {
                completion(nil, NSError(domain: "TemplateService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get templates by category"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 模版详情
    func getTemplateDetail(templateId: String, completion: @escaping (LumaTemplateModel?, Error?) -> Void) {
        NetworkCore.get(path: "api/template/\(templateId)", params: nil) { (data, message) in
            if let templateData = data {
                let template = LumaTemplateModel(json: templateData)
                completion(template, nil)
            } else {
                completion(nil, NSError(domain: "TemplateService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get template detail"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 获取瀑布流数据
    func getGalleryList(page: Int = 1, completion: @escaping (LumaTemplateListModel?, Error?) -> Void) {
        let params: [String: Any] = [
            "page": page
        ]

        NetworkCore.get(path: "api/gallery/list", params: params) { (data, message) in
            if let templateData = data {
                let templateList = LumaTemplateListModel(json: templateData)
                completion(templateList, nil)
            } else {
                completion(nil, NSError(domain: "TemplateService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get gallery list"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    // MARK: - Private Methods

    /// 添加广告标识符到请求参数
    private func addAdvertisingIdentifiers(to params: inout [String: Any], completion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            var advertisingParams: [String: Any] = [:]

            // 获取Adjust AdID
            // advertisingParams["adid"] = Adjust.adid()

            #if os(iOS)
            // iOS平台添加IDFA和IDFV
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        if status == .authorized {
                            advertisingParams["idfa"] = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        }
                        advertisingParams["idfv"] = UIDevice.current.identifierForVendor?.uuidString
                        params.merge(advertisingParams) { (_, new) in new }
                        completion(nil)
                    }
                }
            } else {
                advertisingParams["idfa"] = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                advertisingParams["idfv"] = UIDevice.current.identifierForVendor?.uuidString
                params.merge(advertisingParams) { (_, new) in new }
                completion(nil)
            }
            #else
            // Android平台添加Google AdID
            // advertisingParams["gpsAdid"] = Adjust.googleAdId()
            params.merge(advertisingParams) { (_, new) in new }
            completion(nil)
            #endif
        }
    }
}