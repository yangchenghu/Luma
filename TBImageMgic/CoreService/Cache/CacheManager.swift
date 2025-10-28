//
//  CacheManager.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/30.
//

import Foundation
import YYCache

class CacheManager : NSObject {
    static let shared = CacheManager(name: "local_persist_cache")
    var cache: YYCache?
    
    init(name: String) {
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let cachePath = path.appending("/\(name)")
            cache = YYCache(path: cachePath)
        }
    }
}


