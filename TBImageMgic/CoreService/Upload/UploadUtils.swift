//
//  UploadUtils.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/11.
//

import Foundation

class UploadUtils {

    public class func fileSize(path : String) -> Int64 {
        let manager = FileManager.default
        
        guard manager.fileExists(atPath: path) else { return 0 }
        
        do {
            let attributes = try manager.attributesOfItem(atPath: path)
                
            if let size = attributes[FileAttributeKey.size] as? Int64 {
                return size
            }
        }
        catch {
            
        }
        
        return 0
    }
    

    public class func genUri(prefix : String? = nil) -> String {
        var uri: String
        uri = UUID().uuidString.lowercased()
        uri.insert("/", at: uri.index(uri.startIndex, offsetBy: 4))
        uri.insert("/", at: uri.index(uri.startIndex, offsetBy: 2))
        
        if let prefix = prefix {
            uri = prefix + "/" + uri
        }
        
        return uri
    }

    public class func contentType(for data: Data) -> String {
        var values = [UInt8](repeating:0, count:1)
        data.copyBytes(to: &values, count: 1)
        let ext: String
        switch (values[0]) {
        case 0xFF:
            ext = "jpeg"
        case 0x89:
            ext = "png"
        case 0x47:
            ext = "gif"
        case 0x49, 0x4D :
            ext = "tiff"
        case 0x52:
            if data.count < 12 {
                ext = "png"
            } else {
                let str = String(data: data.prefix(12), encoding: .ascii)
                if str?.hasPrefix("RIFF") == true, str?.hasSuffix("WEBP") == true {
                    ext = "webp"
                } else {
                    ext = "png"
                }
            }
        default:
            ext = "png"
        }
        return ext
    }
    
    
}
