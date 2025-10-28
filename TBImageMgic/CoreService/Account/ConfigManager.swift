
import Foundation


class ConfigManager : NSObject {
    static let shared = ConfigManager()

    var dicInfo : [String : Any] = [:]
    var promptList : [PromptInfo] = []
    var styleList :  [StyleInfo] = []
    
    override init() {
        super.init()
        setup()
    }
    
    
    func setup() {
        
    }
    
    func loadConfig() {
        let api = AIApi.configGet
        api.post { [weak self] data, msg in
            self?.dicInfo = data ?? [:]
            self?.buildConfig()
        } failBlock: { error in
            
        }
    }
    
    func getEmojiList() -> [PromptInfo] {
        promptList
    }
    
}

extension ConfigManager {
    
    func buildConfig() {
        let promptInfoList = dicInfo.arrayDictionaryValueForKey("emoji_prompt_list")
        if promptInfoList.count > 0 {
            promptList = promptInfoList.map{
                PromptInfo(info: $0)
            }
        }
        else {
            promptList = []
        }
        
        if let styleInfoList = dicInfo.arrayDictionaryForKey("style_list"), styleInfoList.count > 0 {
            styleList = styleInfoList.map{
                StyleInfo(info: $0)
            }
        }
        
       
        preloadStyleVideo()
    }
        
    func preloadStyleVideo() {
        guard styleList.count > 0 else { return }
        
        styleList.forEach { style in
            guard style.video_url.count > 0 else { return }
            debugPrint("[config] preload style video:\(style.video_url)")
            ResourceLoader.shared.getItem(url: style.video_url, ext: "mp4") { item, e in
                
            }
        }
    }
    
}


