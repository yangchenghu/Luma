//
//  CreateMenuViewController.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/21.
//

import UIKit
import Foundation

class CreateMenuViewController : UIViewController {
    
    let createTextView : UIView = UIView()
    let createTextBtn : UIButton = UIButton(type: .custom)
    
    let createImgView : UIView = UIView()
    let createImgBtn : UIButton = UIButton(type: .custom)
    
    let closeBtn : UIButton = UIButton(type: .custom)
    
    var clickActionBlock : ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    

}

// UI
extension CreateMenuViewController {
    
    func buildVerticalLayer( colors : [UIColor], points : [NSNumber] = [0.0, 1.0]) -> CAGradientLayer {
        
        let layer = CAGradientLayer()
        let gradientColors = colors.map{
            $0.cgColor
        }
        
        let gradientLocations:[NSNumber] = points
        layer.colors = gradientColors as [Any]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.locations = gradientLocations
        return layer
    }
    
    
    func setupViews() {
        view.backgroundColor = UIColor(hexString: "#1C1C1C")?.withAlphaComponent(0.85)
        
        let bgLayer = buildVerticalLayer(colors: [.clear, UIColor(hexString: "#08071A") ?? .clear])
        bgLayer.frame = view.bounds
        view.layer.addSublayer(bgLayer)
        
        let left : CGFloat = 20
        let right : CGFloat = 20
        let contentWidth : CGFloat = UIScreen.width - left - right
        let space : CGFloat = 20
        
        let closeWidth : CGFloat = 85
        let closeHeight : CGFloat = 87
        
        let viewWidth : CGFloat = min(contentWidth, 353)
        let viewHeight : CGFloat = ceil(viewWidth * 0.75)
        let vLeft : CGFloat = ceil( (UIScreen.width - viewWidth) * 0.5)
        var top : CGFloat = UIScreen.height - UIScreen.bottomSafeHeight - closeHeight - viewHeight - space - viewHeight
        
        createTextView.frame = CGRect(x: vLeft, y: top, width: viewWidth, height: viewHeight)
        createTextView.layer.cornerRadius = 30
        createTextView.layer.masksToBounds = true
        view.addSubview(createTextView)
        
        let txtPlayer = LoopPlayer(frame: createTextView.bounds)
        if let filepath = Bundle.main.path(forResource: "text2Video", ofType: "mp4") {
            txtPlayer.playFile(path: filepath)
        }
        createTextView.addSubview(txtPlayer)
        
        let txtLayer = buildVerticalLayer(colors: [.clear, UIColor(hexString: "#25136D")!.withAlphaComponent(0.21), UIColor(hexString: "#261C4E")!], points: [0.0, 0.7, 1.0])
        txtLayer.frame = CGRect(x: 0, y: viewHeight - 124, width: viewWidth, height: 124)
        createTextView.layer.addSublayer(txtLayer)
      
        
        
        let btnLeft : CGFloat = 16
        let btnRight : CGFloat = 16
        let btnWidth : CGFloat = viewWidth - btnLeft - btnRight
        let btnHeight : CGFloat = 46
        let btnTop : CGFloat = viewHeight - 16 - btnHeight
        
        createTextBtn.frame = CGRect(x: btnLeft, y: btnTop, width: btnWidth, height: btnHeight)
        createTextBtn.layer.cornerRadius = btnHeight * 0.5
        createTextBtn.layer.masksToBounds = true
        createTextBtn.backgroundColor = UIColor(hexString: "#6864F8")
        
        createTextBtn.leftImageStyle(leftImg: UIImage(named: "icon_menu_text2video"), rightText: localizedStr("文字生成视频"), font: .boldSystemFont(ofSize: 16), textColor: .white, space: 8, state: .normal)
        
        createTextBtn.addTarget(self, action: #selector(clickCreateTxtAction), for: .touchUpInside)
        createTextView.addSubview(createTextBtn)
        
        top += createTextView.height
        top += space
        
        createImgView.frame = CGRect(x: vLeft, y: top, width: viewWidth, height: viewHeight)
        createImgView.layer.cornerRadius = 30
        createImgView.layer.masksToBounds = true
        view.addSubview(createImgView)
        
        let imgPlayer = LoopPlayer(frame: createTextView.bounds)
        if let filepath = Bundle.main.path(forResource: "image2Video", ofType: "mp4") {
            imgPlayer.playFile(path: filepath)
        }
        createImgView.addSubview(imgPlayer)
        
        let imgLayer = buildVerticalLayer(colors: [.clear, UIColor(hexString: "#25136D")!.withAlphaComponent(0.21), UIColor(hexString: "#261C4E")!], points: [0.0, 0.7, 1.0])
        imgLayer.frame = CGRect(x: 0, y: viewHeight - 124, width: viewWidth, height: 124)
        createImgView.layer.addSublayer(imgLayer)
        
        createImgBtn.frame = CGRect(x: btnLeft, y: btnTop, width: btnWidth, height: btnHeight)
        createImgBtn.layer.cornerRadius = btnHeight * 0.5
        createImgBtn.layer.masksToBounds = true
        createImgBtn.backgroundColor = UIColor(hexString: "#6864F8")
        createImgBtn.leftImageStyle(leftImg: UIImage(named: "icon_menu_img2video"), rightText: localizedStr("图片生成视频"), font: .boldSystemFont(ofSize: 16), textColor: .white, space: 8, state: .normal)

        createImgBtn.addTarget(self, action: #selector(clickCreateImgAction), for: .touchUpInside)
        createImgView.addSubview(createImgBtn)
        
        
        closeBtn.frame = CGRect(x: (UIScreen.width - closeWidth) * 0.5, y: UIScreen.height - UIScreen.bottomSafeHeight - closeHeight, width: closeWidth, height: closeHeight)
        closeBtn.setImage(UIImage(named: "icons_munu_close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(clickCloseAction), for: .touchUpInside)
        view.addSubview(closeBtn)
    }
}

// action
extension CreateMenuViewController {
    
    @objc func clickCreateTxtAction() {
        clickActionBlock?(1)
        clickCloseAction()
    }
    
    @objc func clickCreateImgAction() {
        clickActionBlock?(2)
        clickCloseAction()
    }
    
    @objc func clickCloseAction() {
        dismiss(animated: false) {
            
        }
    }
    
    
    
}


