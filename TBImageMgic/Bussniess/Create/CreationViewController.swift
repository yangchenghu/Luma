//
//  CreationViewController.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/13.
//

import UIKit
import Foundation
import YYCategories

class CreationViewController : BaseVC {
    
    var image : UIImage?
    
    var imageView : UIImageView = UIImageView()
    var imageContainerView : UIView = UIView()
    
    var exampleId : Int = 0
    let createBtn : UIButton = UIButton(type: .custom)
    
    override init() {
        super.init()
        
        self.showBgImage = true
        self.showHeaderView = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupView()
        
        refreshImage()
    }
    
    
}

// UI
extension CreationViewController {
    
    func setupNav() {
        navHeaderView.backgroundColor = .clear
        
        let changeImgLabel = UILabel(frame: CGRect(x: UIScreen.width - 16 - 100, y: navHeaderView.height - 5 - 34, width: 100, height: 34))
        changeImgLabel.textAlignment = .right
        changeImgLabel.textColor = .white
        changeImgLabel.text = localizedStr("重新选择")
        changeImgLabel.tapBlock = { [weak self] in
            self?.changeImageAction()
        }
        
        navHeaderView.addSubview(changeImgLabel)
    }
    
    func setupView() {
        let imgCTop : CGFloat = navHeaderView.height + 20
        let imgCLeft : CGFloat = 56
        let imgCRight : CGFloat = 56
        let imgCWidth : CGFloat = UIScreen.width - imgCLeft - imgCRight
        let imgCHeight : CGFloat = ceil(imgCWidth / 3 * 4.0)
        
        imageContainerView.frame = CGRect(x: imgCLeft, y: imgCTop, width: imgCWidth, height: imgCHeight)
        imageContainerView.backgroundColor = UIColor(hexString: "#161A28")?.withAlphaComponent(0.53)
        imageContainerView.layer.cornerRadius = 24
        imageContainerView.layer.masksToBounds = true
        imageContainerView.layer.borderWidth = 0.5
        imageContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        view.addSubview(imageContainerView)
        
        
        imageView.frame = imageContainerView.bounds
        imageContainerView.addSubview(imageView)
        
        let top : CGFloat = imageContainerView.bottom + 100
        let leftMargin : CGFloat = 24.0
        let rightMargin : CGFloat = 24.0
        let contentWidth : CGFloat = UIScreen.width - leftMargin - rightMargin
        
        createBtn.frame = CGRect(x: leftMargin, y: top, width: contentWidth, height: 52)
        createBtn.backgroundColor = UIColor(hexString: "#6F72F6")
        createBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        createBtn.setTitleColor(.white, for: .normal)
        createBtn.layer.cornerRadius = 52 * 0.5
        createBtn.layer.masksToBounds = true
        let title : String = localizedStr("AI 自动生成") + "(\(AccountManager.userInfo.consumeCoins)" + "💎)"
        createBtn.setTitle(title, for: .normal)
        createBtn.addTarget(self, action: #selector(clickCreateAction), for: .touchUpInside)
        view.addSubview(createBtn)
    }
    
    func refreshImage() {
        guard let img = image else {
            return
        }
        
        imageView.image = img
        
        let imgWidth : CGFloat = img.size.width
        let imgHeight : CGFloat = img.size.height
        
        guard imgWidth != 0 && imgHeight != 0 else {
            imageView.frame = imageContainerView.bounds
            return
        }
        
        let imgScale : CGFloat = imgWidth / imgHeight
        
        if imgScale < 3.0/4.0 {
            let imgViewHeight : CGFloat = ceil(imgHeight * imageContainerView.width / imgWidth)
            imageView.frame = CGRect(x: 0, y: (imageContainerView.height - imgViewHeight) * 0.5, width: imageContainerView.width, height: imgViewHeight)
            debugPrint("<3/4, frame is:\(imageView.frame)")
        }
        else if imgScale > 3/4 {
            let imgViewWidth : CGFloat = ceil(imgWidth * imageContainerView.height / imgHeight)
            imageView.frame = CGRect(x: (imageContainerView.width - imgViewWidth) * 0.5, y: 0, width: imgViewWidth, height: imageContainerView.height)
            debugPrint(">3/4, frame is:\(imageView.frame)")
        }
        else {
            imageView.frame = imageContainerView.bounds
        }
    }
}


// action
extension CreationViewController {
    
    func changeImageAction() {
        let picker = UIImagePickerController()
//        picker.sourceType = .camera
//        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func clickCreateAction() {
        Reporter.shared.report(event: .create)
    
        
        // 判断是否 价格，拉支付
        let leftCoins = AccountManager.userInfo.coinCnt - AccountManager.userInfo.consumeCoins
        if leftCoins < 0 {
            
            let vc = PayViewController()
            vc.paySuccessBlock = { [weak self] in
//                ProgressHUD.showHud()
                self?.clickCreateAction()
            }
            
            self.presentPanModal(vc)
            
            return
        }
        
        
        guard let img = image else {
            return
        }
        
        HUD.showHud()
        
        let asset = TBImage(img: img)
        let assetId = asset.assetIdentity
        
        PhotoUpload.updateImages(assetList: [asset]) { [weak self] infoMap in
            if let info = infoMap?[assetId] as? [String : Any], let uri = info["uri"] as? String {
                self?.create(imgUri: uri)
            }
            else {
                HUD.hiddenHud()
            }
        }

    }
    
    func create(imgUri : String) {
        let api = AIApi.createCreation(startImg: imgUri, endImg: "", text: "", exampleId: exampleId)
        api.post { [weak self] data, msg in
            if let data {
                HUD.hiddenHud()
                debugPrint(data)
                
                let assetInfo = data.dictValueForKey("assets_info")
                AccountManager.userInfo.update(info: assetInfo)
                
                let creationInfo = data.dictValueForKey("creation_info")
                let creation = CreationInfo(info: creationInfo)
                
                self?.enterDetail(creation: creation)
            }
        } failBlock: { [weak self] error in
            let msg = error?.localizedDescription ?? ""
            debugPrint(msg)
            HUD.hiddenHud()
            Toast.showToast(msg)
            
            if let ret = error?.code, ret == -101 {
                // 余额不足，拉充值
                self?.charge(imgUri: imgUri)
            }
        }
    }
    
    func charge(imgUri : String) {
        let vc = PayViewController()
        vc.paySuccessBlock = { [weak self] in
            HUD.showHud()
            self?.create(imgUri: imgUri)
        }
        
        self.presentPanModal(vc)
    }
    
    func enterDetail(creation : CreationInfo) {
        Reporter.shared.report(event: .create_finish)
        let vc = DetailViewController()
        vc.creation = creation
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CreationViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true)
        
        self.image = image
        refreshImage()
    }
}

extension CreationViewController : UINavigationControllerDelegate {
    
}
