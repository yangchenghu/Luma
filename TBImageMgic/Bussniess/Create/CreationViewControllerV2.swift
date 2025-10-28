
import UIKit
import Foundation
import FSPopoverView

class CreationViewControllerV2 : CreationBaseViewController {
    
    var imageStart : UIImage?
    var imageEnd : UIImage?
    
    var imageCount : Int = 1
    var hasSelectedImageCount : Int = 0
    var exampleId : Int = 0
    var prompt : String?
    
    var startImgUri : String?
    var endImgUri : String?
    var shareName : String = AccountManager.userInfo.userName
    
    var scrollView : UIScrollView = UIScrollView()
    
    var addImgBtn : UIButton = UIButton(type: .custom)
    var startImageView : CuttingImageView!
    var endImageView : CuttingImageView!
    var promptButton : UIButton = UIButton(type: .custom)
    var promptLabel : UILabel = UILabel()
    
    var styleView : CreationStyleView = CreationStyleView()
    
    var durBtnsView : TwoRectButtonsView!
    var modeBtnsView : TwoRectButtonsView!
    
    var modeBtn : UIButton = UIButton(type: .custom)
    var modeTran = FSPopoverViewTransitionScale()
    weak var modeTransition : FSPopoverViewAnimatedTransitioning?
    var modeAlertView : UIView = UIView()
    
    
    var shareTipView : TextDetailView!
    var shareSwitch : UISwitch = UISwitch()
    
    var countTipView : TextDetailView!
    var btnSelectedView : CountSelectedView!

    let createBtn : UIButton = UIButton(type: .custom)
    
//    var styleCode : String = "default"
    var is5sec : Bool = true
    var isHigh : Bool = false
    
    deinit {
        
    }
    
    override init() {
        super.init()
        
        self.showBgImage = true
        self.showHeaderBlur = true
        self.showHeaderView = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupView()
        
        if nil == imageStart {
            Thread.after(seconds: 0.2) { [weak self] in
                self?.changeImageAction()
            }
        }
        else {
            refreshUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubviewToFront(navHeaderView)
    }
    
    
    @objc override func clickCreateAction() {
        Reporter.shared.report(event: .create)
        
        HUD.hiddenHud()
        
        // 判断是否 价格，拉支付
        let leftCoins = AccountManager.userInfo.coinCnt - genCoins()
        
        if leftCoins < 0 {
            let vc = PayViewController()
            vc.paySuccessBlock = { [weak self] in
                HUD.showHud()
                Thread.doInMainThread {
                    self?.clickCreateAction()
                }
            }
            
            self.presentPanModal(vc)
            return
        }
        
        // 开启了分享功能
//        if shareName.count == 0 {
//            let vc = CreationInputNameViewController()
//            vc.submitPromptBlock = { [weak self] text in
//                
//                if text.count > 0 {
//                    self?.shareName = text
//                    AccountManager.userInfo.userName = text
//                }
//                
//                Thread.doInMainThread {
//                    self?.clickCreateAction()
//                }
//            }
//            
//            presentPanModal(vc)
//            return
//        }
        
        guard let startImg = imageStart else {
            changeImageAction()
            return
        }
        
        // 如果有第一张图片，且uri为空
        if startImgUri == nil {
            let asset = TBImage(img: startImg)
            let assetId = asset.assetIdentity
            
            let title = localizedStr("上传图片中") + (imageCount > 1 ? "(1/2)" : "") + "..."
            
            // 没有下载进度
            HUD.showHud(title)
            
            PhotoUpload.updateImages(assetList: [asset]) { fprogress in
                debugPrint("[create] upload progress is:\(fprogress)")
                HUD.progress(fprogress, msg: title)
                
            } finish: { [weak self] infoMap in
                
                if let info = infoMap?[assetId] as? [String : Any], let uri = info["uri"] as? String {
                    self?.startImgUri = uri
                    
//                    if self?.imageCount == 1 {
//                        HUD.progressFinish()
//                    }
                    
                    Thread.doInMainThread {
                        self?.clickCreateAction()
                    }
                }
                else {
                    HUD.hiddenHud()
                }
            }
            
            return
        }
        
        if let endImg = imageEnd, endImgUri == nil {
            let asset = TBImage(img: endImg)
            let assetId = asset.assetIdentity
            let title = localizedStr("上传图片中") + (imageCount > 1 ? "(2/2)" : "") + "..."
            
            // 没有下载进度
            HUD.showHud(title)
            
            PhotoUpload.updateImages(assetList: [asset]) { fprogress in
                HUD.progress(fprogress, msg: title)
                
            } finish: { [weak self] infoMap in
                if let info = infoMap?[assetId] as? [String : Any], let uri = info["uri"] as? String {
                    self?.endImgUri = uri
                    
//                    HUD.progressFinish()
                    
                    Thread.doInMainThread {
                        self?.clickCreateAction()
                    }
                }
                else {
                    HUD.hiddenHud()
                }
            }
            
            return
        }
        
        create()
    }
}

// UI
extension CreationViewControllerV2 {
    
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
        changeBlurAlpha(alpha: 0)
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        var top : CGFloat = UIScreen.topHeight + 12
        let leftMargin : CGFloat = 20.0
        let rightMargin : CGFloat = 20.0
        let contentWidth : CGFloat = UIScreen.width - leftMargin - rightMargin
        
        let imgWidth : CGFloat = 121
        let imgHeight : CGFloat = 146
        
        if 1 == imageCount {
            startImageView = CuttingImageView(frame: CGRect(x: (UIScreen.width - imgWidth) * 0.5, y: top, width: imgWidth, height: imgHeight))
            startImageView.layer.cornerRadius = 14
            startImageView.layer.masksToBounds = true
            scrollView.addSubview(startImageView)
            
            addImgBtn.frame = CGRect(x: startImageView.left + (startImageView.width - 40) * 0.5, y: startImageView.top + (startImageView.height - 40) * 0.5, width: 40, height: 40)
            addImgBtn.backgroundColor = UIColor(hexString: "#6E73F6")
            addImgBtn.setImage(UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
            addImgBtn.layer.cornerRadius = 20
            addImgBtn.layer.masksToBounds = true
            addImgBtn.addTarget(self, action: #selector(changeImageAction), for: .touchUpInside)
            scrollView.addSubview(addImgBtn)
//            addImgBtn.isHidden = true
            
            endImageView = CuttingImageView(frame: CGRectZero)
        }
        else {
            var imgLeft : CGFloat = ceil( (UIScreen.width - imgWidth * 2 - 3) * 0.5 )
            startImageView = CuttingImageView(frame: CGRect(x: imgLeft, y: top, width: imgWidth, height: imgHeight))
            startImageView.layer.cornerRadius = 14
            startImageView.layer.masksToBounds = true
            scrollView.addSubview(startImageView)
            
            imgLeft += imgWidth
            imgLeft += 3
            
            endImageView = CuttingImageView(frame: CGRect(x: imgLeft, y: top, width: imgWidth, height: imgHeight))
            endImageView.layer.cornerRadius = 14
            endImageView.layer.masksToBounds = true
            scrollView.addSubview(endImageView)
        }
        
        top += imgHeight
        top += 29
        
        promptButton.frame = CGRect(x: leftMargin, y: top, width: contentWidth, height: 130)
        promptButton.backgroundColor = UIColor(hexString: "#181629")
        promptButton.layer.cornerRadius = 13
        promptButton.layer.masksToBounds = true
        
        promptLabel.frame = CGRect(x: 14, y: 8, width: contentWidth - 14 - 14 , height: promptButton.height - 16)
        promptLabel.backgroundColor = .clear
        promptLabel.isUserInteractionEnabled = false
        promptLabel.font = .systemFont(ofSize: 16)
        promptLabel.textColor = .white.withAlphaComponent(0.6)
        promptLabel.text = localizedStr("（可选）描述你想象中的视频")
        promptLabel.numberOfLines = 5
        promptLabel.textAlignment = Language.shared.currentLanguageTextAlign()
        promptButton.addSubview(promptLabel)
        promptButton.addTarget(self, action: #selector(clickInputPromptAction), for: .touchUpInside)
        scrollView.addSubview(promptButton)
        
        top += promptButton.height
        top += 32
        
//        let shareTipWidth : CGFloat = contentWidth - 67
//        shareTipView = TextDetailView(frame: CGRect(x: leftMargin, y: top, width: shareTipWidth, height: 60))
//        shareTipView.titleLabel.text = localizedStr("Share with other authors")
//        shareTipView.detailLabel.text = localizedStr("Share your created videos with other creators and receive likes.")
//        scrollView.addSubview(shareTipView)
//        
//        shareSwitch.frame = CGRect(x: shareTipView.right, y: top + 14, width: 67, height: 31)
//        shareSwitch.isOn = true
//        scrollView.addSubview(shareSwitch)
//        
//        top += shareTipView.height
//        top += 32
        
        if ConfigManager.shared.styleList.count > 0 {
            let styleLabel = UILabel(frame: CGRect(x: leftMargin, y: top, width: contentWidth, height: 22))
            styleLabel.font = .systemFont(ofSize: 16)
            styleLabel.textColor = .white
            styleLabel.text = localizedStr("风格模板")
            scrollView.addSubview(styleLabel)
            top += styleLabel.height
            
            styleView.frame = CGRect(x: 0, y: top, width: view.width, height: styleView.viewHeight)
            styleView.changeStyle = { [weak self] prompt in
//                self?.styleCode = mode
                self?.prompt = prompt
                self?.refreshPromptLabel()
            }
            scrollView.addSubview(styleView)
            
            top += styleView.height
            top += 32
        }
        
        let durLabel : UILabel = UILabel(frame: CGRect(x: leftMargin, y: top, width: contentWidth - 150, height: 36))
        durLabel.font = .systemFont(ofSize: 16)
        durLabel.textColor = .white
        durLabel.text = localizedStr("生成时长")
        scrollView.addSubview(durLabel)
        
        durBtnsView = TwoRectButtonsView(frame: CGRect(x: durLabel.right, y: top, width: 150, height: 36))
        durBtnsView.leftBtn.setTitle("5s", for: .normal)
        durBtnsView.rightBtn.setTitle("10s", for: .normal)
        durBtnsView.selectedIndexBlock = { [weak self] index in
            self?.is5sec = (0 == index)
            self?.reloadButtonCoins()
        }
        
        scrollView.addSubview(durBtnsView)
        top += durLabel.height
        top += 32
        
        let modeLabel : UILabel = UILabel(frame: CGRect(x: leftMargin, y: top, width: contentWidth - 206, height: 36))
        modeLabel.font = .systemFont(ofSize: 16)
        modeLabel.textColor = .white
        modeLabel.text = localizedStr("生成模式")
        scrollView.addSubview(modeLabel)
        
        let modeWidth : CGFloat = ceil(modeLabel.sizeThatFits(CGSize(width: 1000, height: 36)).width)
        modeBtn.frame = CGRect(x: modeLabel.left + modeWidth, y: top, width: 36, height: 36)
        modeBtn.setImage(UIImage(systemName: "info.circle")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        modeBtn.addTarget(self, action: #selector(clickHowIsMode(btn:)), for: .touchUpInside)
        
        scrollView.addSubview(modeBtn)
        
        modeBtnsView = TwoRectButtonsView(frame: CGRect(x: modeLabel.right, y: top, width: 206, height: 36))
        modeBtnsView.leftBtn.setTitle(localizedStr("高性能"), for: .normal)
        modeBtnsView.rightBtn.setTitle(localizedStr("高表现"), for: .normal)
        modeBtnsView.selectedIndexBlock = { [weak self] index in
            self?.isHigh = (index == 1)
            self?.reloadButtonCoins()
        }
        
        scrollView.addSubview(modeBtnsView)
        top += durLabel.height
        top += 32
        
        countTipView = TextDetailView(frame: CGRect(x: leftMargin, y: top, width: contentWidth, height: 60))
        countTipView.titleLabel.textAlignment = Language.shared.currentLanguageTextAlign()
        countTipView.titleLabel.text = localizedStr("Select how many videos to generate")
        
        countTipView.detailLabel.textAlignment = Language.shared.currentLanguageTextAlign()
        countTipView.detailLabel.text = localizedStr("You can generate multiple videos simultaneously by AI and select the best result.")
        scrollView.addSubview(countTipView)
        
        top += countTipView.height
        top += 16
        
        btnSelectedView = CountSelectedView(frame: CGRect(x: leftMargin, y: top, width: contentWidth, height: 48))
        btnSelectedView.layoutBtns()
        btnSelectedView.changeBtnSelectedBlock = { [weak self] index in
            self?.reloadButtonCoins()
        }
        
        scrollView.addSubview(btnSelectedView)
        
        top += btnSelectedView.height
        top += 32
        
        createBtn.frame = CGRect(x: leftMargin, y: top, width: contentWidth, height: 52)
        createBtn.backgroundColor = UIColor(hexString: "#6F72F6")
        createBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        createBtn.setTitleColor(.white, for: .normal)
        createBtn.layer.cornerRadius = 52 * 0.5
        createBtn.layer.masksToBounds = true
        let title : String = localizedStr("Create") + "(\(self.genCoins())" + "💎)"
        createBtn.setTitle(title, for: .normal)
        createBtn.addTarget(self, action: #selector(clickCreateAction), for: .touchUpInside)
        scrollView.addSubview(createBtn)
        
        top += createBtn.height
        top += 32
        
        scrollView.contentSize = CGSize(width: UIScreen.width, height: top)
        
        refreshPromptLabel()
        
        
        modeAlertView = UIView(frame: CGRect(x: 0, y: 0, width: 248, height: 150))
        var alertTop : CGFloat = 20
        let alertContentWidth : CGFloat = modeAlertView.width - 16 - 16
        
        let title1Label = UILabel(frame: CGRect(x: 16, y: alertTop, width: alertContentWidth, height: 22))
        title1Label.font = .systemFont(ofSize: 17, weight: .medium)
        title1Label.textColor = .white
        title1Label.textAlignment = Language.shared.currentLanguageTextAlign()
        title1Label.text = localizedStr("高性能")
        modeAlertView.addSubview(title1Label)
        alertTop += title1Label.height
        alertTop += 4
        
        let detail1 = UILabel(frame: CGRect(x: 16, y: alertTop, width: alertContentWidth, height: 18))
        detail1.font = .systemFont(ofSize: 13)
        detail1.textColor = .white.withAlphaComponent(0.6)
        detail1.numberOfLines = 0
        detail1.text = localizedStr("生成速度更快，创作成本更低")
        detail1.textAlignment = Language.shared.currentLanguageTextAlign()
        let detail1Height : CGFloat = ceil(detail1.sizeThatFits(CGSize(width: alertContentWidth, height: 1000)).height)
        detail1.height = detail1Height
        modeAlertView.addSubview(detail1)
        alertTop += detail1Height
        alertTop += 16
        
        let title2Label = UILabel(frame: CGRect(x: 16, y: alertTop, width: alertContentWidth, height: 22))
        title2Label.font = .systemFont(ofSize: 17, weight: .medium)
        title2Label.textColor = .white
        title2Label.textAlignment = Language.shared.currentLanguageTextAlign()
        title2Label.text = localizedStr("高表现")
        modeAlertView.addSubview(title2Label)
        
        let title2Width : CGFloat = ceil(title2Label.sizeThatFits(CGSize(width: 1000, height: title2Label.height)).width)
        
        let title2Image : UIImageView = UIImageView(frame: CGRect(x: title2Label.left + title2Width + 4, y: alertTop + 1, width: 20, height: 20))
        title2Image.image = UIImage(named: "create_mode_star")
        modeAlertView.addSubview(title2Image)
        
        alertTop += title2Label.height
        alertTop += 4
        
        let detail2 = UILabel(frame: CGRect(x: 16, y: alertTop, width: alertContentWidth, height: 18))
        detail2.font = .systemFont(ofSize: 13)
        detail2.textColor = .white.withAlphaComponent(0.6)
        detail2.numberOfLines = 0
        detail2.textAlignment = Language.shared.currentLanguageTextAlign()
        detail2.text = localizedStr("视频画面质量更加，需要更多的制作时间，创作成本高")
        let detail2Height : CGFloat = ceil(detail2.sizeThatFits(CGSize(width: alertContentWidth, height: 1000)).height)
        detail2.height = detail2Height
        modeAlertView.addSubview(detail2)
        alertTop += detail2Height
        alertTop += 20
        modeAlertView.height = alertTop
        
    }
    
    func relayoutViews() {
        var top : CGFloat = startImageView.bottom + 32
        
//        let space : CGFloat = 16
//        if let text = promptLabel.text {
//            let textHeight = Utils.textHeight(text: text, font: promptLabel.font, width: promptLabel.width)
//            
//            if textHeight < 36 {
//                promptButton.height = 36 + space
//                promptLabel.height = 36
//            }
//            else if textHeight > 36 && textHeight < 80 {
//                promptButton.height = textHeight + space
//                promptLabel.height = textHeight
//            }
//            else {
//                promptButton.height = 80 + space
//                promptLabel.height = 80
//            }
//        }
//        else {
//            promptButton.height = 46
//            promptLabel.height = 46 - space
//        }
        promptButton.height = 130
        if let text = promptLabel.text {
            let textHeight = Utils.textHeight(text: text, font: promptLabel.font, width: promptLabel.width)
            promptLabel.height = min(textHeight, promptButton.height - 20)
        }
        
        top += promptButton.height
        top += 32
        
        if ConfigManager.shared.styleList.count > 0 {
            top += 22
            styleView.top = top
            top += styleView.height
            top += 32
        }
        
        top += 36
        top += 32
        
        top += 36
        top += 32
        
        countTipView.top = top
        top += countTipView.height
        top += 16
        
        btnSelectedView.top = top
        
        top += btnSelectedView.height
        top += 32
        
        createBtn.top = top
        
        top += createBtn.height
        top += 32
        
        scrollView.contentSize = CGSize(width: UIScreen.width, height: top)
    }
    
//    func refreshButtonTitle(cnt : Int) {
//        let title : String = localizedStr("Create") + "(\(AccountManager.userInfo.img2VideoCoins * cnt)" + "💎)"
//        createBtn.setTitle(title, for: .normal)
//    }
    
    // 数据齐全，刷新页面
    func refreshUI() {
        startImageView.image = imageStart
        addImgBtn.isHidden = (imageStart != nil)
        durBtnsView.index = is5sec ? 0 : 1
        modeBtnsView.index = isHigh ? 1 : 0
        
        durBtnsView.layoutViews()
        modeBtnsView.layoutViews()
        
        refreshPromptLabel()
        
//        reloadButtonCoins()
    }
    
    
    func reloadButtonCoins() {
        let coins = genCoins()
        let title : String = localizedStr("Create") + "(\(coins)" + "💎)"
        createBtn.setTitle(title, for: .normal)
    }
    
    func genCoins() -> Int {
        let asset = AccountManager.userInfo
        let coin = is5sec ? (isHigh ? asset.coinHigh5s : asset.coin5s ) : ( isHigh ? asset.coinHigh10s : asset.coin10s)
        let count = (btnSelectedView.selectedIndex + 1)
        return coin * count
    }
    
    func refreshPromptLabel() {
        if let text = prompt, text.count > 0 {
            promptLabel.textColor = .white
            promptLabel.text = text
        }
        else {
            promptLabel.textColor = .white.withAlphaComponent(0.6)
            promptLabel.text = localizedStr("（可选）描述你想象中的视频")
        }
        
        relayoutViews()
    }
}


// action
extension CreationViewControllerV2 {
   
    
    @objc func changeImageAction() {
        
        startImgUri = nil
        endImgUri = nil
        
        hasSelectedImageCount = 0
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func clickInputPromptAction() {
        let vc = CreationInputAlterViewController()
        vc.inputText = prompt
        vc.submitPromptBlock = { [weak self] text in
            self?.prompt = text
            self?.refreshPromptLabel()
            self?.styleView.reset()
        }
        
        presentPanModal(vc)
    }
    
    @objc func clickHowIsMode(btn : UIButton) {
        modeTransition = modeTran
        
        let popoverView = FSPopoverView()
        popoverView.arrowDirection = .up
        popoverView.dataSource = self
        popoverView.showsArrow = true
        popoverView.borderWidth = 0
        popoverView.shadowOpacity = 0
        popoverView.showsDimBackground = true
        popoverView.transitioningDelegate = modeTransition
        popoverView.present(fromView: btn)
    }
    
    
    func create() {
        let text : String = prompt ?? ""
        let share : Bool = shareSwitch.isOn
        let count : Int = btnSelectedView.selectedIndex + 1
        
        HUD.showHud(localizedStr("发布中") + "...")
        
        let api = AIApi.image2Video(startImg: startImgUri ?? "", endImage: endImgUri ?? "", text: text, can_share: share, user_name: shareName, cnt: count, exampleId: exampleId, style: "", dur: is5sec ? 5 : 10, mode: isHigh ? "high" : "normal")
        api.post { [weak self] data, msg in
            if let data {
                HUD.hiddenHud()
                debugPrint(data)
                
                let assetInfo = data.dictValueForKey("assets_info")
                AccountManager.userInfo.update(info: assetInfo)
                
                let list = data.arrayDictionaryValueForKey("creation_list")
                let creationList = list.map { CreationInfo(info: $0) }
                
                if let creation = creationList.first, creation.creationId != 0 {
                    self?.enterDetail(creation: creation)
                    LibraryViewDataSource.shared.loadData()
                }
                else {
                    let error : String = localizedStr("creation error") + "!!!"
                    Toast.showToast(error)
                }
            }
        } failBlock: { [weak self] error in
            let msg = error?.localizedDescription ?? ""
            debugPrint(msg)
            HUD.hiddenHud()
            Toast.showToast(msg)
            
            if let ret = error?.code, ret == -101 {
                // 余额不足，拉充值
                self?.charge()
            }
        }
    }
    
}


extension CreationViewControllerV2 : FSPopoverViewDataSource {
    func backgroundView(for popoverView: FSPopoverView) -> UIView? {
        let view = UIView(frame: popoverView.bounds)
//        view.backgroundColor = UIColor(hexString: "#8C8C8C")
        let blur = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blur)
        effectView.frame = view.bounds
        view.addSubview(effectView)
        
        return view
    }
    
    func contentView(for popoverView: FSPopoverView) -> UIView? {
        modeAlertView
    }
    
    func popoverViewShouldDismissOnTapOutside(_ popoverView: FSPopoverView) -> Bool {
        true
    }
    
    func contentSize(for popoverView: FSPopoverView) -> CGSize {
        modeAlertView.size
    }
    
    
}


extension CreationViewControllerV2 : UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        if startImgUri == nil {
            addImgBtn.isHidden = false
        }
        else {
            addImgBtn.isHidden = true
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        if 0 == hasSelectedImageCount {
            imageStart = image
            startImageView.image = image
            hasSelectedImageCount = 1
            
            // 如果选中了图片，就消失
            addImgBtn.isHidden = true
            
            if 2 == imageCount {
                Toast.showToast(localizedStr("请选择第二张图片"))
            }
        }
        else if 1 == hasSelectedImageCount {
            imageEnd = image
            endImageView.image = image
            hasSelectedImageCount = 2
        }
        
        if hasSelectedImageCount == imageCount {
            picker.dismiss(animated: true)
            addImgBtn.isHidden = true
        }
    }
}

extension CreationViewControllerV2 : UINavigationControllerDelegate {
    
}

extension CreationViewControllerV2 : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let navHeight : CGFloat = UIScreen.navBarHeight + UIScreen.statusBarHeight
        
        let yOffset = scrollView.contentOffset.y
        if yOffset < 0 {
            changeBlurAlpha(alpha: 0)
        }
        else {
            let alpha : CGFloat = (yOffset / navHeight) * 2
            changeBlurAlpha(alpha: alpha)
        }
    }
}


class TextDetailView: UIView {
    var titleLabel : UILabel = UILabel()
    var detailLabel : UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: width, height: 22)
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .white
        addSubview(titleLabel)
        
        detailLabel.frame = CGRect(x: 0, y: 22, width: width, height: 38)
        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.textColor = .white.withAlphaComponent(0.64)
        detailLabel.numberOfLines = 0
        addSubview(detailLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 0, y: 0, width: width, height: 22)
        detailLabel.frame = CGRect(x: 0, y: 22, width: width, height: 38)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

