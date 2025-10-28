//
//  LumaUserService.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import Foundation
import AdSupport
import AppTrackingTransparency

@objcMembers
class LumaUserService: NSObject {

    static let shared = LumaUserService()

    // 当前用户信息
    private(set) var currentUser: LumaUserModel?
    private(set) var isLoggedIn: Bool = false

    // 用户信息更新回调
    typealias UserInfoUpdateBlock = (LumaUserModel?) -> Void
    private var userInfoUpdateBlocks: [UserInfoUpdateBlock] = []

    private override init() {
        super.init()
        loadCachedUserInfo()
    }

    // MARK: - Public Methods

    /// 添加用户信息更新监听
    func addUserInfoUpdateBlock(_ block: @escaping UserInfoUpdateBlock) {
        userInfoUpdateBlocks.append(block)
    }

    /// 移除用户信息更新监听
    func removeUserInfoUpdateBlock(_ block: UserInfoUpdateBlock) {
        if let index = userInfoUpdateBlocks.firstIndex(where: { $0 === block }) {
            userInfoUpdateBlocks.remove(at: index)
        }
    }

    /// 用户登录
    func login(deviceId: String, completion: @escaping (LumaUserModel?, Error?) -> Void) {
        var params: [String: Any] = ["deviceId": deviceId]

        // 添加广告标识符
        addAdvertisingIdentifiers(to: &params) { [weak self] error in
            guard error == nil else {
                completion(nil, error)
                return
            }

            NetworkCore.post(path: "api/user/app/login", params: params) { [weak self] (data, message) in
                guard let self = self else { return }

                if let userData = data {
                    let user = LumaUserModel(json: userData)
                    self.currentUser = user
                    self.isLoggedIn = user.isLoggedIn
                    self.cacheUserInfo(user)
                    self.notifyUserInfoUpdate()
                    completion(user, nil)
                } else {
                    completion(nil, NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Login failed"]))
                }
            } failBlock: { error in
                completion(nil, error)
            }
        }
    }

    /// 获取用户信息
    func getUserInfo(completion: @escaping (LumaUserModel?, Error?) -> Void) {
        let params: [String: Any] = ["userId": getUserId()]

        NetworkCore.get(path: "api/user/info", params: params) { [weak self] (data, message) in
            guard let self = self else { return }

            if let userData = data {
                self.currentUser?.update(with: userData)
                self.cacheUserInfo(self.currentUser)
                self.notifyUserInfoUpdate()
                completion(self.currentUser, nil)
            } else {
                completion(nil, NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Failed to get user info"]))
            }
        } failBlock: { error in
            completion(nil, error)
        }
    }

    /// 退出登录
    func logout() {
        currentUser = nil
        isLoggedIn = false
        clearCachedUserInfo()
        NetworkConfig.shared.token = nil
        notifyUserInfoUpdate()
    }

    /// 获取用户ID
    func getUserId() -> String {
        return currentUser?.id ?? ""
    }

    /// 获取用户Token
    func getUserToken() -> String? {
        return currentUser?.token
    }

    /// 获取用户显示名称
    func getDisplayName() -> String {
        return currentUser?.displayName ?? "User"
    }

    /// 获取用户金币数量
    func getCoinCount() -> Int {
        return currentUser?.coinCnt ?? 0
    }

    /// 检查用户是否有足够的金币
    func hasEnoughCoins(_ requiredCoins: Int) -> Bool {
        return getCoinCount() >= requiredCoins
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

    /// 通知用户信息更新
    private func notifyUserInfoUpdate() {
        DispatchQueue.main.async {
            self.userInfoUpdateBlocks.forEach { $0(self.currentUser) }
        }
    }

    // MARK: - User Info Caching

    /// 缓存用户信息
    private func cacheUserInfo(_ user: LumaUserModel?) {
        guard let user = user else { return }

        let userDefaults = UserDefaults.standard
        let encoder = JSONEncoder()

        if let encodedData = try? encoder.encode([
            "id": user.id ?? "",
            "token": user.token ?? "",
            "points": user.points,
            "email": user.email ?? "",
            "nick": user.nick ?? "",
            "username": user.username ?? "",
            "coinCnt": user.coinCnt
        ]) {
            userDefaults.set(encodedData, forKey: "CachedUserInfo")
        }

        // 缓存token到网络配置
        NetworkConfig.shared.token = user.token
    }

    /// 加载缓存的用户信息
    private func loadCachedUserInfo() {
        let userDefaults = UserDefaults.standard

        guard let data = userDefaults.data(forKey: "CachedUserInfo"),
              let userInfo = try? JSONDecoder().decode([String: Any].self, from: data) else {
            return
        }

        let user = LumaUserModel(json: userInfo)
        self.currentUser = user
        self.isLoggedIn = user.isLoggedIn

        // 恢复token到网络配置
        NetworkConfig.shared.token = user.token
    }

    /// 清除缓存的用户信息
    private func clearCachedUserInfo() {
        UserDefaults.standard.removeObject(forKey: "CachedUserInfo")
    }
}