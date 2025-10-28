

import Foundation
import UIKit

/// image 对应状态  可扩展
enum LotImageStatus: Int {
    case normal = 0
    case selected
    case highlight
}

/// 配置类
final class LotImageViewConfig {
    
    fileprivate var imageStatusMap: [LotImageStatus: String] = [:]
    private(set) var lotFolder: (bundle: String, name: String)?
    private(set) var lotFolderDark: (bundle: String, name: String)?
    var lotSize: CGSize
    var imageSize = CGSize.zero
    
    /// 配置非bundle 资源
    var lotPath: String?
    var lotPathDark: String?
    fileprivate var imageMap: [LotImageStatus: UIImage] = [:]
    
    init(
        normal: String,
        selected: String?,
        lotFolder: (bundle: String, name: String)?,
        darkModeLotFolder: (bundle: String, name: String)? = nil,
        lotSize: CGSize
    ) {
        self.lotFolder = lotFolder
        self.lotFolderDark = darkModeLotFolder
        self.lotSize = lotSize
        setImageName(normal, forStatus: .normal)
        setImageName(selected, forStatus: .selected)
    }
    
    /// 添加图片名及状态
    func setImageName(_ name: String?, forStatus status: LotImageStatus) {
        imageStatusMap[status] = name
    }
    /// 添加已有图片及状态
    func setImage(_ image: UIImage?, forStatus status: LotImageStatus) {
        imageMap[status] = image
    }
}

final class LotImageView: UIView {
    
    private(set) var imageView: UIImageView!
    var config: LotImageViewConfig
    private weak var lotView: LOTAnimationView?
    private var currentStatus: LotImageStatus?
    var status: LotImageStatus {
        if let s = currentStatus {
            return s
        }
        return .normal
    }
    
    override init(frame: CGRect) {
        config = LotImageViewConfig(normal: "", selected: "", lotFolder: ("", ""), lotSize: .zero)
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        addSubview(imageView)
    }
    
    init(frame: CGRect, config: LotImageViewConfig) {
        self.config = config
        super.init(frame: frame)
        if config.imageSize.equalTo(CGSize.zero) {
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        } else {
            let size = config.imageSize
            imageView = UIImageView(frame: CGRect(x: (frame.width - size.width) / 2.0, y: (frame.height - size.height) / 2.0, width: size.width, height: size.height))
        }
        if let name = config.imageStatusMap[.normal] {
            imageView.image = UIImage(named: name)
        }
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imgSize: CGSize
        if config.imageSize.equalTo(CGSize.zero) {
            imgSize = CGSize(width: bounds.width, height: bounds.height)
        } else {
            imgSize = config.imageSize
        }
        imageView.frame = CGRect(x: (frame.width - imgSize.width) / 2.0, y: (frame.height - imgSize.height) / 2.0, width: imgSize.width, height: imgSize.height)
    }
    
    func resetConfig(_ config: LotImageViewConfig) {
        self.config = config
        let imgSize: CGSize
        if config.imageSize.equalTo(CGSize.zero) {
            imgSize = CGSize(width: frame.width, height: frame.height)
        } else {
            imgSize = config.imageSize
        }
        imageView.frame = CGRect(x: (frame.width - imgSize.width) / 2.0, y: (frame.height - imgSize.height) / 2.0, width: imgSize.width, height: imgSize.height)
        if config.imageMap.isEmpty {
            if let name = config.imageStatusMap[status] {
                imageView.image = UIImage(named: name)
            } else if let name = config.imageStatusMap[.normal] {
                imageView.image = UIImage(named: name)
            }
        } else {
            if let img = config.imageMap[status] {
                imageView.image = img
            } else if let img = config.imageMap[.normal] {
                imageView.image = img
            }
        }
    }
    
    func setStatus(_ status: LotImageStatus, animation: Bool = true) {
        if currentStatus == status {
            return
        }
        currentStatus = status
        lotView?.stop()
        lotView?.removeFromSuperview()
        if config.imageMap.isEmpty {
            if let name = config.imageStatusMap[status] {
                imageView.image = UIImage(named: name)
            } else if let name = config.imageStatusMap[.normal] {
                imageView.image = UIImage(named: name)
            }
        } else {
            if let img = config.imageMap[status] {
                imageView.image = img
            } else if let img = config.imageMap[.normal] {
                imageView.image = img
            }
        }
        if let path = config.lotPath, !FileManager.default.fileExists(atPath: path) {
            imageView.isHidden = false
            return
        }
        if animation {
            let oprationLotView: LOTAnimationView?
            if let path = config.lotPath, path.count > 0 {
                oprationLotView = LOTAnimationView.animationWithFilePath(path, darkModeFilePath: config.lotPathDark)
            } else if let path = config.lotFolder {
                let pathDark = config.lotFolderDark
                oprationLotView = LOTAnimationView(bundle: path.bundle, forder: path.name, darkModeBundle: pathDark?.bundle, darkModeForder: pathDark?.name)
            } else {
                oprationLotView = nil
            }
            if let lotView = oprationLotView {
                imageView.isHidden = true
                lotView.frame = CGRect(x: imageView.frame.minX + (imageView.frame.width - config.lotSize.width) / 2.0, y: imageView.frame.minY + (imageView.frame.height - config.lotSize.height) / 2.0, width: config.lotSize.width, height: config.lotSize.height)
                lotView.loopAnimationCount = 1
                lotView.contentMode = .scaleAspectFit
                addSubview(lotView)
                self.lotView = lotView
                self.lotView?.play { [weak self] (finish) in
                    self?.imageView.isHidden = false
                    self?.lotView?.removeFromSuperview()
                }
            } else {
                imageView.isHidden = false
            }
        } else {
            imageView.isHidden = false
        }
    }
    
    func stop() {
        setStatus(.normal, animation: false)
    }
    
    func playToEnd(_ animation: Bool = true) {
        setStatus(.selected, animation: animation)
    }
}
