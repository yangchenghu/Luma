
import Foundation
import Photos

class PhotoUploadTask {
    var index : Int = 0
    let asset: TBImageProtocol
    var progress : ((_ index : Int, _ uploadProgress : CGFloat ) -> Void)?
    var config: S3UploadRequestConfig = S3UploadRequestConfig()
    var client: S3Uploader = S3Uploader()
    init(asset: TBImageProtocol) {
        self.asset = asset
    }
    
    deinit {
        debugPrint("-----------")
    }
    
    func update(finish: (([String : Any]) -> Void)?) {
        /// 获取图片data
        let index = index 
        asset.requestImageData { [weak self] (data, info) in
            let imgWidth : CGFloat = info[ImageInfoKeyWidth] as! CGFloat
            let imgHeight : CGFloat = info[ImageInfoKeyHeight] as! CGFloat
            
            self?.config.build(imageData: data)
            self?.config.imageSize = CGSize(width: imgWidth, height: imgHeight)
            self?.config.progressBlock = { fprogress in
                self?.progress?(index, fprogress)
            }
            self?.config.completionBlock = { error, info in
                finish?(info)
            }
            
            self?.startS3Upload()
        }
    }
    
    private func startS3Upload() {
        client.start(config: config)
    }
    
}

class PhotoUpload {
    static func updateImages(assetList: [TBImageProtocol], progress : ((CGFloat) -> Void)? = nil, finish: (([String : [String : Any]]?) -> Void)?) {
        uploadMedia(assetList: assetList, progress: progress, finish: finish)
    }
   
    /// 3.上传media资源
    private static func uploadMedia(assetList: [TBImageProtocol], progress : ((CGFloat) -> Void)? = nil, finish: (([String : [String : Any]]?) -> Void)?) {
        
        var index : Int = 0
        let onePart : CGFloat = (0.95 / CGFloat(assetList.count))
        var tasks: [PhotoUploadTask] = assetList.map { asset in
            let task = PhotoUploadTask(asset: asset)
            task.index = index
            task.progress = { index, uploadProgress in
                let upProgress : CGFloat = ( CGFloat(index) * onePart) + uploadProgress * onePart
                progress?(upProgress)
            }
            
            index += 1
            return task
        }
        var imgInfoList: [String : [String : Any]] = [:]
        func uploadSingle() {
            if tasks.count > 0, let task = tasks.first {
//                unowned let retval = task.asset
                let assetId = task.asset.assetIdentity
                task.update { info in
                    tasks.removeFirst()
                    if let uri = info["uri"] as? String, uri.count > 0 {
                        imgInfoList[assetId] = info
                        uploadSingle()
                    }
                    else {
                        finish?(nil)
                    }
                }
            }
            else {
                finish?(imgInfoList)
            }
        }
        uploadSingle()
    }
    
//    static func config() {
//        
//    }
}
