
import Foundation

class StyleInfo : NSObject {
    
    var title : String = ""
    var video_url : String = ""
    var webp_url : String = ""
    var prompt : String = ""
    
    init(info : [String : Any] ) {
        title = info.stringValueForKey("title")
        video_url = info.stringValueForKey("video_url")
        webp_url = info.stringValueForKey("webp_url")
        prompt = info.stringValueForKey("prompt")
    }
    
}
