//
//  CreationInfo.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/12.
//

import Foundation

class CreationInfo : NSObject {
    
    enum UpDownStatus : Int {
        case up = 1
        case unowned = 0
        case down = -1
    }
    
    
    enum CreationStatus : Int {
        case inProgress = 10
        case finish = 20
        case fail = -10
    }
    
    enum CreationType : String {
        case unowned = ""
        case txt2Video = "text2video"
        case img2Video = "image2video"
    }
    
    var startImgUrl : String = ""  // 开始图片的地址
    var endImgUrl : String = ""    // 结束图片的地址
    var text : String = ""
    var videoUrl : String = ""
    var status : CreationStatus = .inProgress
    var coinCnt : Int = 0    // 消耗金币数
    var creationId : Int64 = 0
    var userName : String = ""  // 分享的用户名
    
    var createTime : Int64 = 0     // 创作时间
    var finishTime : Int64 = 0      // 完成时间
    
    var estimatedLoadingTime : Int64 = 0  // 预估的制作时间，没有的话，页面随机给 4-7分钟时间
    
    var createString : String = ""
    
    var btnText : String = ""
    var exampleId : Int = 0
    
    var creationGroupId : Int = 0
    var deviceId : String = ""
    
    var upDown : UpDownStatus = .unowned
    
    var type : CreationType = .unowned
    
    var coin_cnt_remake : Int = 2
    var dur : Int = 5
    var mode_option : String = "normal"
    
    init(info : [String : Any]) {
        startImgUrl = info.stringValueForKey("img_url_start")
        endImgUrl = info.stringValueForKey("img_url_end")
        text = info.stringValueForKey("text")
        videoUrl = info.stringValueForKey("video_url")
        
        creationId = info.int64ValueForKey("creation_id")
        userName = info.stringValueForKey("user_name")
        
        coinCnt = info.intValueForKey("coin_cnt")
        
        let iStatus = info.intValueForKey("status")
        status = CreationStatus(rawValue: iStatus) ?? .inProgress
        
        btnText = info.stringValueForKey("button_text")
        exampleId = info.intValueForKey("creation_example_id")
        
        createTime = info.int64ValueForKey("ct")
        finishTime = info.int64ValueForKey("et")
        
        estimatedLoadingTime = info.int64ValueForKey("estimated_loading_time")
        
        creationGroupId = info.intValueForKey("creation_group_id")
        
        deviceId = info.stringValueForKey("did")
        
        let upAndDown = info.intValueForKey("updown")
        upDown = UpDownStatus(rawValue: upAndDown) ?? .unowned
        
        if createTime > 0 {
            createString = Self.yearReadableTime(createTime)
        }
        
        let strType = info.stringValueForKey("type")
        type = CreationType(rawValue: strType) ?? .unowned
        
        coin_cnt_remake = info.intValueForKey("coin_cnt_remake")
        
        dur = info.intForKey("dur") ?? 5
        mode_option = info.stringForKey("mode_option") ?? "normal"
    }
}

extension CreationInfo {
    static func yearReadableTime(_ time: Int64) -> String {
        let thatDate = Date(timeIntervalSince1970: TimeInterval(time))
        let formate = DateFormatter()
        formate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formate.string(from: thatDate)
    }
    
    
}
