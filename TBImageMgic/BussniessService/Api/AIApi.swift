
import Foundation

// AI 相关接口

enum AIApi: NetworkApiProtocol {
    /// 注册token
    case registerGuest
    
    // 获取我的金币数量
    case getMyCoin
    
    // 获取我的作品
    case getMyCreations
    
    // 首页内容
    case homePage
    
    // --------- 商品相关
    
    // 商品列表
    case productList
    // 创建商品订单
    case orderCreate(productId : Int64)
    // 充值完成
    case orderFinish(orderId : Int64, receiptData : String)
    
    // 制作作品 v1
    case createCreation(startImg : String, endImg : String , text : String, exampleId : Int)
    // 作品详情
    case creationDetail(creation_id : Int64)
    
    // 制作作品 v2
    // https://mock.aibaturu.com/project/11/interface/api/53
    case createCreation_v2(startImg : String, endImage : String, text : String, can_share: Bool, user_name : String, cnt : Int, exampleId : Int, style : String, dur : String, mode : String)
    
    // /account/creation_image2video_submit
    // https://app.apifox.com/project/5117283
    case image2Video(startImg : String, endImage : String, text : String, can_share: Bool, user_name : String, cnt : Int, exampleId : Int, style : String, dur : Int, mode : String)
    
    // 拉取作品列表
    // https://mock.aibaturu.com/project/11/interface/api/69
    case creationList(group_id : Int)
    
    // 拉取用户分享的作品列表
    // https://mock.aibaturu.com/project/11/interface/api/77
    case shareCreationList(user_did : String)
    
    // 拉取首页用户分享作品列表
    // https://mock.aibaturu.com/project/11/interface/api/85
    case homeShareCreationList(next_cb : String)
    
    // 删除作品
    case deleteCreation(creation_id : Int64)
    
    // 批量获取作品状态
    case creationsInfo(list : [Int64])
    
    
    // 1.0.4 版本变化
    
    // 商品列表
    case productList_v2
    
    // 点赞点踩
    case creationUpDown(creation_id : Int64, status: Int)
    
    // 重新制作
    case creationRemake(creation_id : Int64)
    
    // 获取配置信息
    case configGet
    
    // 文字生成作品
    case createTextCreation(text : String, can_share : Bool, user_name : String, cnt: Int)
    
}

extension AIApi {
    var path: String {
        switch self {
        case .registerGuest:
            return "account/guest_register"
        case .getMyCoin:
            return "account/my_assets"
        case .getMyCreations:
            return "account/my_creations"
        case .homePage:
            return "recommend/home_page"
        case .productList:
            return "product/product_list"
        case .orderCreate:
            return "product/order_create"
        case .orderFinish:
            return "product/order_submit"
        case .createCreation:
            return "account/creation_submit"
        case .createCreation_v2:
            return "account/creation_submit_v2"
        case .image2Video:
            return "account/creation_image2video_submit"
        case .creationDetail:
            return "account/creation_get"
            
        case .creationList:
            return "account/creations_get_by_group_id"
            
        case .shareCreationList:
            return "user/get_shared_creations"
            
        case .homeShareCreationList:
            return "recommend/get_shared_creations"
        
        case .deleteCreation:
            return "account/creation_delete"
            
        case .creationsInfo:
            return "account/creations_get_by_ids"
        
        case .productList_v2:
            return "product/product_list_v2"
            
        case .creationUpDown:
            return "account/creation_updown"
            
        case .creationRemake:
            return "account/creation_remake"
            
        case .configGet:
            return "config/get"
            
        case .createTextCreation:
            return "account/creation_text2video_submit"
            
        }
        
    }
}

extension AIApi {
    var parameters: [String: Any] {
        switch self {
        case .registerGuest:
            return [:]
        case .getMyCoin:
            return [:]
        case .getMyCreations:
            return [:]
        case .homePage:
            return [:]
        case .productList:
            return [:]
        case .orderCreate(let productId):
            return [ "product_id" : productId]
        case .orderFinish(let orderId, let receiptData):
            return [ "order_id" : orderId, "receipt_data" : receiptData]
        case .createCreation(let startImg, let endImg, let text, let exampleId):
            return [ "img_url_start" : startImg, "img_url_end" : endImg , "text" : text, "creation_example_id" : exampleId]
            
        case .createCreation_v2(let startImg, let endImage, let text, let can_share, let user_name, let cnt , let exampleId, let style, let dur , let mode):
            return ["img_url_start" : startImg, "img_url_end" : endImage, "text" : text, "can_share" : can_share, "user_name" : user_name, "cnt" : cnt, "creation_example_id" : exampleId, "prompt_id" : style, "dur_option" : dur, "mode_option" : mode]
            
        case .image2Video(let startImg, let endImage, let text, let can_share, let user_name, let cnt , let exampleId, let style, let dur , let mode):
            return ["img_url_start" : startImg, "img_url_end" : endImage, "text" : text, "can_share" : can_share, "user_name" : user_name, "cnt" : cnt, "creation_example_id" : exampleId, "prompt_id" : style, "dur_option" : dur, "mode_option" : mode]
            
            
        case .creationDetail(let creation_id):
            return ["creation_id" : creation_id]
            
        case .creationList(let group_id):
            return ["creation_group_id" : group_id]
            
        case .shareCreationList(let user_did):
            return ["did_shared" : user_did]
            
        case .homeShareCreationList(let next_cb):
            return ["next_cb" : next_cb]
        
        case .deleteCreation( let creation_id):
            return ["creation_id" : creation_id]
            
        case .creationsInfo(let list):
            return ["creation_ids" : list]
            
        case .productList_v2:
            return [:]
            
        case .creationUpDown(let creation_id, let status):
            return ["creation_id" : creation_id, "updown" : status]
            
        case .creationRemake( let creation_id):
            return ["creation_id" : creation_id]
        
        case .configGet:
            return [:]
        
        case .createTextCreation(let text, let can_share, let user_name, let cnt):
            return ["text" : text, "can_share" : can_share, "user_name" : user_name, "cnt" : cnt]
        }
    }
}

