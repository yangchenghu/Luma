//
//  TBImage.swift
//  TBImageMgic
//
//  Created by wplive on 2024/8/11.
//

import UIKit
import Foundation
import SDWebImage


public let ImageInfoKeyContentType : String = "kImageInfoKeyContentType"
public let ImageInfoKeyWidth : String = "kImageInfoKeyWidth"
public let ImageInfoKeyHeight : String = "kImageInfoKeyHeight"
public let ImageInfoKeyLength : String = "kImageInfoKeyLength"


protocol TBImageProtocol {
    var assetIdentity : String { set get}
    
    func requestImageData ( callBack : ( Data, [String : Any]) -> Void)
}

extension TBImageProtocol {
    
}

extension UIImage {
   
}


class TBImageUtils : NSObject {
    
    static func imageType(data : Data) -> String {
        let type = NSData.sd_imageFormat(forImageData: data)
        switch type {
        case .JPEG:
            return "jpeg"
        case .PNG:
            return "png"
        case .webP:
            return "webp"
        case .SVG:
            return "svg"
        case .PDF:
            return "pdf"
        case .GIF:
            return "gif"
        case .TIFF:
            return "tiff"
        case .HEIC:
            return "heic"
        case .TIFF:
            return "tiff"
        case .undefined:
            return "undefined"
        default:
            return "unknowed"
        }
    }
}

class TBImage : TBImageProtocol {
    
    var assetIdentity: String
        
    var image : UIImage?
    
    init( img : UIImage) {
        self.image = img
        assetIdentity = UUID().uuidString.md5
    }
    
    func requestImageData(callBack: (Data, [String : Any]) -> Void) {
        
        guard let img = image else {
            return
        }
        
        if var imgData = img.pngData() {
            let imgType = TBImageUtils.imageType(data: imgData)
            let isGif = (imgType == "gif")
            if imgType == "jpeg", let jpegData = img.jpegData(compressionQuality: 0.8) {
                imgData = jpegData
            }
            let imgCount = imgData.count
            let imgWidth : CGFloat = img.size.width
            let imgHeight : CGFloat = img.size.height
            
            let info : [String : Any] = [
                ImageInfoKeyContentType : imgType,
                ImageInfoKeyWidth : imgWidth,
                ImageInfoKeyHeight : imgHeight,
                ImageInfoKeyLength : imgCount
            ]
                        
            callBack(imgData, info)
        }
    }
}


