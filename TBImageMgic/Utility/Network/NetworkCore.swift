//
//  NetworkCore.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/31.
//

import Foundation
import Alamofire

public let kNotifictionTokenExpired : NSNotification.Name = NSNotification.Name("tb.network.token.expired")

public typealias NetworkSuccessBlock = (_ data: [String : Any]?, _ msg: String?) -> ()
public typealias NetworkFailBlock = (_ error : NSError?) -> ()

public protocol NetworkApiProtocol {
    var path: String { get }
    var parameters: [String : Any] { get }
    func post(successBlock : @escaping NetworkSuccessBlock, failBlock : @escaping NetworkFailBlock)
}

extension NetworkApiProtocol {
    func post(successBlock : @escaping NetworkSuccessBlock, failBlock : @escaping NetworkFailBlock) {
        NetworkCore.post(path: path, params: parameters, successBlock: successBlock, failBlock: failBlock)
    }
}

class NetworkConfig : NSObject {
    public static let shared = NetworkConfig()
    
    var apiHost : String = "https://tserver.singlow.xyz"
    var token : String?
    
    var baseParams : [String : Any] {
        var params : [String : Any] = innerParams
        if let token = token, token.count > 0 {
            params["token"] = token
        }
        
        return params
    }
    
    private var innerParams : [String : Any] = [:]
    
    func buildBaseParams() {
        innerParams["h_dt"] = 10 // iOS
        innerParams["h_did"] = NetworkUtils.deviceId()
        innerParams["h_lang"] = NetworkUtils.currentLanguage()
        innerParams["h_av"] = "\(NetworkUtils.appVersionForAPI())"
        innerParams["h_os"] = NetworkUtils.systemVerNumber()
        innerParams["h_model"] = UIDevice.current.model
    }
    
    func buildUrl(path : String) -> String {
        apiHost + "/" + path
    }
    
    func buildParams(params : [String : Any]?) -> [String : Any] {
        var base = baseParams
        if let p = params {
            for (key, value) in p {
                base[key] = value
            }
        }
        return base
    }
    
}

class NetworkCore : NSObject {
    
    public class func post(
        path : String,
        params : [String : Any]? = nil,
        successBlock : NetworkSuccessBlock? = nil,
        failBlock : NetworkFailBlock? = nil)
    {
        let url = NetworkConfig.shared.buildUrl(path: path)
        let postParams = NetworkConfig.shared.buildParams(params: params)
        sendRequest(url: url, method: .post, params: postParams, successHandle:successBlock, failHandle:failBlock)
    }
    
    
    private class func sendRequest(
        url: String,
        method: HTTPMethod = .post,
        params: [String : Any] ,
        successHandle: NetworkSuccessBlock? = nil,
        failHandle: NetworkFailBlock? = nil)
    {
//        var requiredHeaders = HTTPHeaders()
//        if let token = getTokenFromStorage() {
//            requiredHeaders.add(name: "Authorization", value: "Bearer " + token)
//        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        AF.request(request).response { response in
            switch response.result {
            case .success(let data):
                func resultCallBack(result: Dictionary<String, Any>) {
                    let ret = (result["ret"] as? NSInteger) ?? -9999
                    let message = result["msg"] as? String
                    if ret == 1 {
                        if let handle = successHandle  {
                            handle(result["data"] as? [String : Any], message)
                        }
                    }
                    else if ret == -11 { // token 过期
                        NotificationCenter.default.post(name: kNotifictionTokenExpired, object: nil)
                    }
                    else {
                        if let handle = failHandle {
                            debugPrint("[network] error")
                            handle(nil)
                        }
                    }
                }
                
                if let data = data,  let dicResponse = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers), let dicData = dicResponse as? [String : Any] {
//                    debugPrint("[TB] response dic is:\(dicResponse)")
                    resultCallBack(result: dicData)
                }
                else {
                    if let handle = failHandle {
                        handle(nil)
                    }
                }
            case .failure(let error):
                if let handle = failHandle {
                    handle(error as NSError)
                }
            }
            
        }
    }
    
 
    // 下载方法
    public class func download(from url: String, params : [String : Any]? = [:], to destinationURL: URL? = nil, progressHandler: ((Double) -> Void)?, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        
        AF.download(url, parameters: params, to: (destinationURL == nil ? nil :  { _, _ in (destinationURL!, [.removePreviousFile, .createIntermediateDirectories]) } ) )
            .downloadProgress { progress in
                progressHandler?(progress.fractionCompleted)
            }
            .response { response in
                switch response.result {
                case .success(let fileURL):
                    if let fileURL = fileURL {
                        completionHandler(.success(fileURL))
                    } 
                    else {
                        completionHandler(.failure(NSError(domain: "DownloadManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "File URL is nil."])))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }

    
    
    
}


