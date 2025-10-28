
import Foundation
//import YYCache

class ResourceItem {
    
    var url : String = ""
    var filepath : String = ""
    var key : String = ""
    var ext : String = ""
    var isFile : Bool = true
    var isZip : Bool = false
//    var fileSize : Int64 = 0
    var progress : ((CGFloat) -> Void)?
    
    var filename : String {
        return key + "." + ext
    }
    
    var fileUrl : URL {
        var fileUrl : URL
        if #available(iOS 16.0, *) {
            fileUrl = URL(filePath:filepath)
        } else {
            fileUrl = URL(fileURLWithPath:filepath)
        }
        return fileUrl
    }
    
    init(url: String, ext : String) {
        self.url = url
        self.key = url.md5
        self.ext = ext
    }
    
    init( info : [String : Any]) {
        key = info.stringValueForKey("key")
        ext = info.stringValueForKey("ext")
        isFile = info.boolValueForKey("isfile")
    }
        
    func setPath(path : String) {
        if isFile {
            filepath = path + "/" + key + "." + ext
        }
        else {
            filepath = path + "/" + key
        }
    }
    
    func toJson() -> [String : Any] {
        var json : [String : Any] = [:]
        json["key"] = key
        json["ext"] = ext
        json["isfile"] = isFile
        return json
    }
}

class ResourceLoader {
    static let shared = ResourceLoader()
    
    var cache : [String : ResourceItem] = [:]
    let cacheKey : String = "resource_looad_cache_key_1"
    
    private var downloading : [String] = []
    
    init() {
        prepare()
        readCache()
    }
    
    /// ext 文件扩展名
    func getItem(url : String, ext: String, progress : ((CGFloat) -> Void)? = nil, completion: @escaping ((ResourceItem?, Error?) -> Void)) {
        
        let key = url.md5
        let path = cachePath()
        if let item = cache[key] {
            if item.filepath.isEmpty {
                item.setPath(path: path)
            }
            
            completion(item, nil)
            return
        }
        
        let item = ResourceItem(url: url, ext: ext)
        item.setPath(path: path)
        item.progress = progress
        
        downloadItem(item: item, completion: completion)
    }
    
    func buildItem(url : String, ext : String) -> ResourceItem {
        
        let key = url.md5
        let path = cachePath()
        // 如果在缓存中找到，直接返回，
        if let item = cache[key] {
            if item.filepath.isEmpty {
                item.setPath(path: path)
            }
            
            return item
        }
        
        let item = ResourceItem(url: url, ext: ext)
        item.setPath(path: path)
        return item
    }
    
    
    //
    func hasCacheUrl(url : String, ext : String) -> Bool {
        let key = url.md5
        let path = cachePath()
        // 如果在缓存中找到，直接返回，
        if let item = cache[key] {
            if item.filepath.isEmpty {
                item.setPath(path: path)
            }
            
            return false
        }
        
        return false
    }
}

// MARK: Private
extension ResourceLoader {
    
    private func documentPath() -> String {
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last {
            return path
        }
        return ""
    }
    
    private func cachePath() -> String {
        documentPath() + "/" + "resouce"
    }
    
    private func prepare() {
        let path = cachePath()
        let filemanager = FileManager.default
        if !filemanager.fileExists(atPath: path) {
            do {
                try filemanager.createDirectory(atPath: path, withIntermediateDirectories: false)
            }
            catch {
                
            }
        }
    }
    
    private func readCache() {
        let list = CacheManager.shared.cache?.object(forKey: cacheKey)
        
        guard let jsonList = list as? [[String : Any]] else {
            return
        }
        
        let path : String = cachePath()
        
        jsonList.forEach { dicItem in
            let item = ResourceItem(info: dicItem)
            item.setPath(path: path)
            cache[item.key] = item
        }
    }
    
    private func saveCache() {
        let list = cache.values.map { $0.toJson() }
        if list.count == 0 {
            return
        }
        
        CacheManager.shared.cache?.setObject(list as NSCoding, forKey: cacheKey)
    }
    
    private func downloadItem(item : ResourceItem, completion: @escaping ((ResourceItem?, Error?) -> Void)) {
        debugPrint("[TB] resource: start download item:\(item.key)")
        
        if FileManager.default.fileExists(atPath: item.filepath) {
            debugPrint("[TB] download file Exist:\(item.filepath)")
            completion(item, nil)
            return
        }
        
        // 正在downloading
        if downloading.contains(item.key) {
            debugPrint("[TB] resource: downloading item:\(item.key)")
            return
        }
        
        downloading.append(item.key)
        let targetUrl : URL = URL(fileURLWithPath: item.filepath)

        NetworkCore.download(from: item.url, to: targetUrl) { fprogress in
            item.progress?(fprogress)
        } completionHandler: { [weak self] result in
            self?.downloading.remove(item.key)
            switch result {
            case let .success(url) :
                debugPrint("[TB] download file:\(item.key) url is:\(url)")
//                var path : String = url.absoluteString
//                if url.isFileURL {
//                    path = url.relativePath
//                }
//                
//                let filemanager = FileManager.default
//                do {
//                    try filemanager.moveItem(atPath: path, toPath: item.filepath)
//                }
//                catch {
//                    debugPrint("catch error is:\(error)")
//                }
                if let hasItem = self?.cache[item.key] {
                    debugPrint("[TB] resource: find cache item:\(item.key)")
                    return
                }
                
                self?.cache[item.key] = item
                self?.saveCache()
                completion(item, nil)
            case let .failure(e) :
                debugPrint("[TB] dwonload fail:\(e)")
                completion(nil, e)
            }
        }

        
        
        
//        NetworkCore.download(urlStr: item.url, parameters: [:], progress: item.progress) { [weak self] result in
//            switch result {
//            case let .success(url) :
//                var path : String = url?.absoluteString ?? ""
//                if let local = url, local.isFileURL {
//                    path = local.relativePath
//                }
//                
//                let filemanager = FileManager.default
//                do {
//                    try filemanager.moveItem(atPath: path, toPath: item.filepath)
//                }
//                catch {
//                    debugPrint("catch error is:\(error)")
//                }
//                
//                self?.cache[item.key] = item
//                self?.saveCache()
//                completion(item, nil)
//            case let .failure(e) :
//                debugPrint("[resource] dwonload fail:\(e)")
//                completion(nil, e)
//            }
//        }
    }
}
