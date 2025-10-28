
import Foundation

class AccountManager {
    static let shared = AccountManager()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateExpiredToken), name: kNotifictionTokenExpired, object: nil)
    }
    
    func setup() {
        if nil == NetworkConfig.shared.token
            || NetworkConfig.shared.token == "" {
            getToken()
        }
    }
    
    
    @objc func updateExpiredToken() {
        getToken()
    }
}

extension AccountManager {
    
    public static var userInfo : AssetsInfo = AssetsInfo()
    
    func updateMoney() {
        let api = AIApi.getMyCoin
        api.post { data, msg in
            if let data {
                debugPrint(data)
            }
            
        } failBlock: { error in
            let msg = error?.localizedDescription ?? ""
            debugPrint("error is:\(msg)")
        }
    }
    
    public static var creationList : [CreationInfo] = []
    
    // 更新我的作品
    func updateMyCreations() {
        let api = AIApi.getMyCreations
        api.post { data, msg in
            if let data {
                debugPrint(data)
                let assetInfo = data.dictValueForKey("assets_info")
                Self.userInfo.update(info: assetInfo)
                
                let list = data.arrayDictionaryValueForKey("creation_list")
                let creationList : [CreationInfo] = list.map{ CreationInfo(info: $0) }
                
                Self.creationList = creationList
            }
        } failBlock: { error in
            let msg = error?.localizedDescription ?? ""
            debugPrint("error is:\(msg)")
        }
    }
    
    func updateMyAsset() {
        let api = AIApi.getMyCoin
        api.post { data, msg in
            if let data {
                debugPrint(data)
                let assetInfo = data.dictValueForKey("assets_info")
                Self.userInfo.update(info: assetInfo)
            }
        } failBlock: { error in
            debugPrint(error)
        }
    }
    
    /// 刷新token
    static var updating = false
    
    func getToken() {
        debugPrint("get token....")
        guard Self.updating == false else {
            return
        }
        Self.updating = true
        debugPrint("post get token request")
        let api = AIApi.registerGuest
        api.post { [weak self] data, msg in
            if let data {
                let token = data.stringValueForKey("token")
//                URLManager.userToken = token
                NetworkConfig.shared.token = token
                debugPrint("get token is:\(token)")
                
                ConfigManager.shared.loadConfig()
                
                self?.updateMyAsset()
                Self.updating = false
                
                NotificationCenter.default.post(name: NSNotification.Name("accoount.get.token"), object: nil)
            }
        } failBlock: { error in
            debugPrint("get token error is:\(error)")
            Self.updating = false
            // 如果token授权失败，退出登录
        }

//        api.post { [weak self] result in
//            switch result {
//            case let .success(data):
//                let token = data.stringValueForKey("token")
//                URLManager.userToken = token
//                UserDefaults.standard.set(token, forKey: "accoount.guest.token")
//                debugPrint("[account] save cache token is:\(token)")
//                
//                self?.updateMyAsset()
//                Self.updating = false
//                
//                NotificationCenter.default.post(name: NSNotification.Name("accoount.get.token"), object: nil)
//            case let .failure(error):
//                debugPrint("get token error is:\(error)")
//                Self.updating = false
//                // 如果token授权失败，退出登录
//                
//            }
//        }
    }
}
