

import UIKit
import Foundation
import L10n_swift


func localizedStr(_ key: String) -> String {
    L10n.shared.string(for:key)
//    return NSLocalizedString(key, comment: "")
}

public let kLanguageChangedNotification = NSNotification.Name(rawValue: "LanguageChangedNotification")

class Language : NSObject {
    
    static let shared = Language()
    
    private let languageList : [[String : String]] = [
        ["label" : "English", "code" : "EN", "lang" : "en"],
        ["label" : "中文", "code" : "ZH", "lang" : "zh-Hans"],
        ["label" : "Português", "code" : "PT", "lang" : "pt-PT"],
        ["label" : "Español", "code" : "ES", "lang" : "es"],
        ["label" : "Русский", "code" : "RU", "lang" : "ru"],
        ["label" : "日本語", "code" : "JA", "lang" : "ja"],
        ["label" : "қазақ", "code" : "KK", "lang" : "kk"],
        ["label" : "عربي", "code" : "AR", "lang" : "ar"],
    ]
    
    override init() {
        super.init()
        
        debugPrint("[TB] current lang is:\(L10n.shared.language)")
        
        L10n.shared.language = UserDefaults.standard.string(forKey: "AppLanguage") ?? L10n.shared.language
    }
    
    
    public func currentLanguage() -> String {
        L10n.shared.language
    }
    
    // 大写code
    public func currentLanguageCode() -> String {
        let lang : String = L10n.shared.language
        let langTitle : String = languageList.first(where: {
            $0["lang"] == lang
        })?["code"] ?? "EN"
        
        return langTitle
    }
    
    // 当前语言的对齐方式
    public func currentLanguageTextAlign() -> NSTextAlignment {
        let code = currentLanguage()
        if code == "ar" {
            return .right
        }
        
        return .left
    }
    
    public func languageTitls() -> [String] {
        let currentLang = L10n.shared.language
        let titlesList : [String] = languageList.map{
            var title = $0["label"] ?? ""
            let lang = $0["lang"] ?? "en"
            if lang == currentLang {
                title = " " + title + " ✓"
            }
            
            return title
        }
        
        return titlesList
    }
    
    public func changeLanguage(index : Int) {
        var lange : String = "en"
        if index < languageList.count {
            let item = languageList[index]
            let lang : String = item["lang"] ?? "en"
            lange = lang
        }
        
        L10n.shared.language = lange
        UserDefaults.standard.set(lange, forKey: "AppLanguage")
                
        NotificationCenter.default.post(name: kLanguageChangedNotification, object: nil)
    }
}


