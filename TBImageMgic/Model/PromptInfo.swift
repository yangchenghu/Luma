

import Foundation

class PromptInfo : NSObject {
    var title : String = ""
    var detail : String = ""
    
    init(info : [String : Any]) {
        title = info.stringValueForKey("emoji")
        detail = info.stringValueForKey("prompt")
    }
    
}

