//
//  S3Uploader.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/11.
//


import Foundation
import CoreGraphics


enum S3Api : NetworkApiProtocol {
    
    case preSignUrl(config : S3UploadRequestConfig)

    var path: String {
        switch self {
        case .preSignUrl :
            return "media/s3_pre_sign_url_v2"
        }
    }
        
    var parameters: [String : Any] {
        switch self {
        case .preSignUrl(let config) :
            var params : [String : Any] = [:]
            params["bucket_type"] = config.isImage ? "image" : "video"
            params["uri"] = config.fileName
            params["content_type"] = config.contentType
            params["content_length"] = config.fileSize
            
//            if config.partCount > 2 {
//                params["upload_id"] = config.uploadId
//                params["part_number"] = config.currentPart + 1
//            }
            
            return params
        }
    }
}

class S3UploadRequestConfig {
    var isImage : Bool = true
    var fileName : String = ""  // uri
    var filePath : String = ""
    var fileData : Data = Data()
    var fileSize : Int = 0
    
    var imageSize : CGSize = CGSizeZero
    var contentType : String = ""
    var index : Int = 0   // 第几张
    
    var progressBlock : ((CGFloat) -> Void)?
    var completionBlock : ((NSError?, [String : Any]) -> Void)?
    
    // 分片上传的时候会用到
    var partCount : Int = 1
    var partSize : Int = 0
    
    var currentPart : Int = 0
    var uploadId : String = ""
    
    
    init() {
        partSize = 20 * 1024 * 1024 // 20m 分片
        
    }
    
    func build(imageData : Data) {
        isImage = true
        fileName = UploadUtils.genUri(prefix: kAppInnerName)
        fileData = imageData
        fileSize = imageData.count
        contentType = UploadUtils.contentType(for: imageData)
    }
    
    
    
}

class S3Uploader : NSObject {
    
    weak var config : S3UploadRequestConfig?
    
    
    func start( config : S3UploadRequestConfig ) {
        self.config = config
        
        if config.partCount < 2 {
            // 单片上传
            requestSingleUploadInfo()
        }
        else {
            // 启动分片上传
            
        }
    }
    
    
    private func requestSingleUploadInfo() {
        guard let config = config else {
            return
        }
        
        let api = S3Api.preSignUrl(config: config)
        api.post { [weak self] data, msg in
            if let data {
                debugPrint("--get presign url 成功")
                if let url = data["presigned_url"] as? String, let header = data["signed_header"] as? [String : [String]] {
                    self?.uploadSingle(url: url, headers: header)
                }
                else if let completion = config.completionBlock {
                    completion(NSError(domain: "com.luma", code: -998, userInfo: [NSLocalizedDescriptionKey : "can not find url"]), [:])
                }
            }
        } failBlock: { error in
            if let completion = config.completionBlock {
                completion(error, [:])
            }
        }

//        api.post { [weak self] result in
//            switch result {
//            case let .success(data):
//                debugPrint("--get presign url 成功")
//                if let url = data["url"] as? String, let header = data["signed_header"] as? [String : [String]] {
//                    self?.uploadSingle(url: url, headers: header)
//                }
//                
//            case let .failure(error):
//                if let completion = config.completionBlock {
//                    completion(error as NSError, [:])
//                }
//            }
//        }
    }
    
    private func uploadSingle(url : String, headers : [String : [String]]) {
        guard let uploadUrl = URL(string: url) else {
            return
        }
        
        var request = URLRequest(url: uploadUrl)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "PUT"

        if #available(iOS 12.0, *) {
            request.networkServiceType = .responsiveData
        }

        for (key, list) in headers {
            request.setValue(list.first, forHTTPHeaderField: key)
        }

        let sharedSession = URLSession.shared
        
        var task : URLSessionTask
        if let path = config?.filePath, path.count > 0 {
            var fileUrl : URL
            if #available(iOS 16.0, *) {
                fileUrl = URL(filePath: path)
            } else {
                fileUrl = URL(fileURLWithPath: path)
            }
            
            task = sharedSession.uploadTask(with: request, fromFile: fileUrl) { [weak self] data, response, error in
                debugPrint("上传完成：\(String(describing: error))")
                if let error = error {
                    self?.uploadError(error: error as NSError)
                } else {
                    self?.uploadFinished()
                }
            }
        }
        else if let data = config?.fileData, data.count > 0 {
            task = sharedSession.uploadTask(with: request, from: data, completionHandler: { [weak self] data, response, error in
                if let error = error {
                    self?.uploadError(error: error as NSError)
                } else {
                    self?.uploadFinished()
                }
            })
        }
        else {
            debugPrint("error")
            return
        }
        
        if #available(iOS 15.0, *) {
            task.delegate = self
        }

        task.resume()
    }
    
    private func uploadFinished() {
        guard let config = config, let completion = config.completionBlock else {
            return
        }
        
        var info : [String : Any] = [:]
        if config.isImage {
            let fmt : String = config.contentType
            let uri : String = config.fileName
            let h : CGFloat = config.imageSize.height
            let w : CGFloat = config.imageSize.width
            let resId : String = config.fileName
            let resType : String = config.contentType == "gif" ? "gif" : "img"
            
            info = [
                "fmt" : fmt,
                "h" : h,
                "w" : w,
                "id" : 0,
                "resid" : resId,
                "restype" : resType,
                "uri" : uri
            ]
        }
        else {
           // TODO:
            
        }
        
        completion(nil, info)
    }
    
    private func uploadError(error : NSError?) {
        guard let fail = config?.completionBlock else {
            return
        }
        
        fail(error, [:])
    }
}

extension S3Uploader : URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        guard let config = config, let progressBlock = config.progressBlock, totalBytesExpectedToSend != 0 else {
            return
        }
        
        let progress = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
        
        progressBlock(progress)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let config = config else {
            return
        }
        
        if let e = error {
            uploadError(error: e as NSError)
        }
        else {
            uploadFinished()
        }
    }
}
