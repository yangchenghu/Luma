//
//  DetailViewController.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/13.
//

import UIKit
import Foundation

class DetailViewController : BaseVC {
    
    var creation : CreationInfo?
    
    var loadingAnimationView : LOTAnimationView = .init(frame: CGRect(x: -120, y: 0, width: 120, height: 120))
    var loadingTitle = UILabel()
    var loadingLabel = UILabel()
    
    var counterLabel : CountdownView?
    var finishView : UIImageView = UIImageView()
    
    var cardView : CreationCardView = CreationCardView()
    
    var twoBtns : TwoButtonsView!
    var btnsView : UIView = UIView()
    
    let upDownView : DetailUpDownView = DetailUpDownView()
    let upImageView : UIImageView = UIImageView(frame: CGRect(x: -120, y: 0, width: 180, height: 120))
    
    var showDetailBtn : UIButton = UIButton(type: .custom)
    
    var groupViewOriginTop : CGFloat = 0
    var groupView : DetailGroupCreationListView!
    
    var backBtn : UIButton = UIButton(type: .custom)
    var timer : Timer?
    
    deinit {
        endTimer()
    }
    
    override init() {
        super.init()
        
        self.showNavTitle = true
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
        
        refreshData()
    }
    
}

// UI
extension DetailViewController {
    
    func setupNav() {
        navHeaderView.backgroundColor = .clear
    }
    
    func setupView() {
        guard let creation = creation else {
            debugPrint("--error detail not creation")
            return
        }
        
//        let left : CGFloat = 24.0
//        let right : CGFloat = 24.0
//        let contentWidth : CGFloat = UIScreen.width - left - right
//        let bottom : CGFloat = 42.0
//        
//        let btnHeight : CGFloat =  52.0
//        let mainColor : UIColor? = UIColor(hexString: "#6F72F6")
//        let btnFont : UIFont = .boldSystemFont(ofSize: 16)

        if creation.status == .inProgress {
            setupLaodingView()
        }
        else {
            setupFinishView()
        }
    }
    
    func setupLaodingView() {
        let left : CGFloat = 24.0
        let right : CGFloat = 24.0
        let contentWidth : CGFloat = UIScreen.width - left - right
        let bottom : CGFloat = 42.0
        
        let btnHeight : CGFloat =  52.0
        let mainColor : UIColor? = UIColor(hexString: "#6F72F6")
        let btnFont : UIFont = .boldSystemFont(ofSize: 16)
        
        // 中间整体200高度 // 20 是lottie设计80，文件120，偏移20
        let loadingTop : CGFloat = ceil((UIScreen.height - 210) * 0.5) - 20
        
        finishView.frame = CGRect(x: (UIScreen.width - 270) * 0.5, y: loadingTop - 80, width: 270, height: 218)
        finishView.image = UIImage(named: "pic_generation_finish_bg")
        view.addSubview(finishView)
        
        let finishIcon = UIImageView(frame: CGRect(x: (finishView.width - 82) * 0.5, y: 77, width: 82, height: 82))
        finishIcon.image = UIImage(named: "pic_generation_finish")
        finishView.addSubview(finishIcon)
        
        let finishLabel = UILabel(frame: CGRect(x: 0, y: finishView.height - 13 - 25, width: finishView.width, height: 25))
        finishLabel.textAlignment = .center
        finishLabel.font = .boldSystemFont(ofSize: 20)
        finishLabel.textColor = .white
        finishLabel.text = localizedStr("已完成")
        finishView.addSubview(finishLabel)
        finishView.alpha = 0
        
        var btnTop = view.height - UIScreen.bottomSafeHeight - bottom - btnHeight - 20 - btnHeight
        showDetailBtn.frame = CGRect(x: left, y: btnTop, width: contentWidth, height: btnHeight)
        showDetailBtn.layer.cornerRadius = btnHeight * 0.5
        showDetailBtn.layer.masksToBounds = true
        showDetailBtn.layer.borderWidth = 1
        showDetailBtn.backgroundColor = mainColor
        showDetailBtn.titleLabel?.font = btnFont
        showDetailBtn.setTitleColor(.white, for: .normal)
        showDetailBtn.setTitle(localizedStr("立刻查看"), for: .normal)
        showDetailBtn.addTarget(self, action: #selector(clickShowDetail), for: .touchUpInside)
        view.addSubview(showDetailBtn)
        showDetailBtn.alpha = 0
        
        let loadingWidth : CGFloat = 120
        loadingAnimationView.frame = CGRect(x: (UIScreen.width - loadingWidth) * 0.5, y: loadingTop, width: loadingWidth, height: loadingWidth)
        
        if let path : String = Bundle.main.path(forResource: "detail_loading", ofType: "json") {
            loadingAnimationView.filePath = (light: path, dark: path)
            loadingAnimationView.loopAnimationCount = -1
            view.addSubview(loadingAnimationView)
        }
            
        var top : CGFloat = loadingTop + loadingWidth
        
        loadingTitle.frame = CGRect(x: 50, y: top, width: UIScreen.width - 100, height: 22)
        loadingTitle.textAlignment = .center
        loadingTitle.font = .boldSystemFont(ofSize: 17)
        loadingTitle.textColor = .white
        loadingTitle.text = localizedStr("驯服AI中")
        view.addSubview(loadingTitle)
        
        top += loadingTitle.height
        top += 4
        
        loadingLabel.frame = CGRect(x: 50, y: top, width: UIScreen.width - 100, height: 22)
        loadingLabel.textAlignment = .center
        loadingLabel.font = .systemFont(ofSize: 14)
        loadingLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        loadingLabel.text = localizedStr("预计完成时间") + ":"
        view.addSubview(loadingLabel)
        
        top += loadingLabel.height
        top += 11
        
        let counter = CountdownView(frame: CGRect(x: (view.width - 144) * 0.5, y: top, width: 144, height: 39))
        view.addSubview(counter)
        counterLabel = counter
        
        btnTop = view.height - UIScreen.bottomSafeHeight - bottom - btnHeight
        backBtn.frame = CGRect(x: left, y: btnTop, width: contentWidth, height: btnHeight)
        backBtn.layer.cornerRadius = btnHeight * 0.5
        backBtn.layer.masksToBounds = true
        backBtn.layer.borderWidth = 1
        backBtn.layer.borderColor = mainColor?.cgColor
        backBtn.titleLabel?.font = btnFont
        backBtn.setTitleColor(mainColor, for: .normal)
        backBtn.setTitle(localizedStr("返回首页"), for: .normal)
        backBtn.addTarget(self, action: #selector(clickBackToHome), for: .touchUpInside)
        view.addSubview(backBtn)
        
        
    }
    
    func setupFinishView() {
        guard let creation = creation else { return }
        
        let remakeCoin : Int = creation.coin_cnt_remake
        
        if remakeCoin > 0 {
            let retryBtn = UIButton(type: .custom)
            let retryTitle = "(" + "\(creation.coin_cnt_remake)" + "💎)"
            let retryFont = UIFont.systemFont(ofSize: 17)
            let textWidth : CGFloat = Utils.textWidth(text: retryTitle, font: retryFont, height: 22)
            let retryWidth : CGFloat = max(70, 44 + 2 + textWidth + 8)
            
            retryBtn.frame = CGRect(x: UIScreen.width - 16 - retryWidth , y: UIScreen.statusBarHeight, width: retryWidth, height: 44)
            if let retryImg : UIImage = UIImage(named: "icons_remake") {
                retryBtn.leftImageStyle(leftImg: retryImg, rightText: retryTitle, font: retryFont, textColor: .white, space: 2, state: .normal)
            }
//        retryBtn.titleLabel?.font = retryFont
//        retryBtn.setTitle(retryTitle, for: .normal)
            retryBtn.addTarget(self, action: #selector(showRebuildAlert), for: .touchUpInside)
            navHeaderView.addSubview(retryBtn)
        }
        
        let left : CGFloat = 24.0
        let right : CGFloat = 24.0
        let contentWidth : CGFloat = UIScreen.width - left - right
        let bottom : CGFloat = 32.0
        
        let btnHeight : CGFloat =  52.0
        let mainColor : UIColor? = UIColor(hexString: "#6F72F6")
        let btnFont : UIFont = .boldSystemFont(ofSize: 16)
        
        let imgCTop : CGFloat = UIScreen.topHeight + 20
        let imgCLeft : CGFloat = 70
        let imgCRight : CGFloat = 70
        let imgCWidth : CGFloat = UIScreen.width - imgCLeft - imgCRight
        let imgCHeight : CGFloat = ceil(imgCWidth * 1.255)
        
        cardView.frame = CGRect(x: imgCLeft, y: imgCTop, width: imgCWidth, height: imgCHeight)
        cardView.backgroundColor = UIColor(hexString: "#161A28")?.withAlphaComponent(0.53)
        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = true
        cardView.layer.borderWidth = 0.5
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        view.addSubview(cardView)
        
        var top : CGFloat = cardView.bottom + 20
        let btnsLeft : CGFloat = ceil( (UIScreen.width - 140) * 0.5 )
        
        if creation.type != .txt2Video {
            twoBtns = TwoButtonsView(frame: CGRect(x: btnsLeft, y: top, width: 140, height: 38))
            twoBtns.selectedIndexBlock = { [weak self] index in
                let player = self?.cardView.player
                player?.isHidden = ( 0 != index)
            }
            view.addSubview(twoBtns)
            top += twoBtns.height
            top += 40
        }
        
        upDownView.frame = CGRect(x: left, y: top, width: contentWidth, height: 94)
        view.addSubview(upDownView)
        
        upDownView.clickUpBlock = { [weak self] in
            self?.showUpAnimation()
            self?.reportUpDownStatus(status: 1)
        }
        
        upDownView.clickDownBlock = { [weak self] in
            self?.reportUpDownStatus(status: -1)
            self?.showRebuildAlert()
        }
        
        let upWidth : CGFloat = 180
        let upHeight : CGFloat = 120
        let upTop : CGFloat = upDownView.top - 13
        
        upImageView.frame = CGRect(x: (UIScreen.width - upWidth) * 0.5, y: upTop, width: upWidth, height: upHeight)
        
        top += upDownView.height
        top += 40
        
        let btnsTop = view.height - UIScreen.bottomSafeHeight - bottom - btnHeight - 28 - btnHeight
        btnsView.frame = CGRect(x: left, y: btnsTop, width: contentWidth, height: btnHeight)
        btnsView.layer.cornerRadius = btnHeight * 0.5
        btnsView.layer.masksToBounds = true
        view.addSubview(btnsView)
        
        let singleBtnWidth : CGFloat = floor( (contentWidth - 2) * 0.5 )
        let btnTitleColor : UIColor = UIColor(red: 0.875, green: 0.865, blue: 0.991, alpha: 1)
        
        let downloadBtn = UIButton(type: .custom)
        downloadBtn.frame = CGRect(x: 0, y: 0, width: singleBtnWidth, height: btnHeight)
        downloadBtn.backgroundColor = mainColor
        downloadBtn.leftImageStyle(leftImg: UIImage(named: "icon_button_download"), rightText: localizedStr("保存视频"), font: btnFont, textColor: btnTitleColor, space: 0, state: .normal)
        downloadBtn.addTarget(self, action: #selector(clickDownloadAction), for: .touchUpInside)
        btnsView.addSubview(downloadBtn)
        
        let rebuildBtn = UIButton(type: .custom)
        rebuildBtn.frame = CGRect(x: 2 + singleBtnWidth, y: 0, width: singleBtnWidth, height: btnHeight)
        rebuildBtn.backgroundColor = mainColor
        rebuildBtn.titleLabel?.font = btnFont
        rebuildBtn.setTitleColor(btnTitleColor, for: .normal)
        rebuildBtn.setTitle(localizedStr("再做一张"), for: .normal)
        rebuildBtn.addTarget(self, action: #selector(clickRebuildAction), for: .touchUpInside)
        btnsView.addSubview(rebuildBtn)
        
        // 底部漏出64
        let groupHeight : CGFloat = view.height - 117
        groupViewOriginTop = view.height - 64 - UIScreen.bottomSafeHeight
        groupView = DetailGroupCreationListView(frame: CGRect(x: 0, y: groupViewOriginTop, width: UIScreen.width, height: groupHeight), isTemp: false)
        groupView.clickHiddenBlock = { [weak self] in
            self?.hiddenGroupList()
        }
        
        groupView.clickShowBlock = { [weak self] in
            self?.showGroupList()
        }
        
        groupView.clickDeleteBlock = { [weak self] creation in
            self?.groupDelete(creation: creation)
        }
        
        view.addSubview(groupView)
        
    }
    
    func refreshData() {
        
        guard let creation = creation else {
            debugPrint("--- error")
            return
        }
        
        if creation.status == .inProgress {
            canDragBack(can: false)
            navBackBtn.isHidden = true
            
            loadingAnimationView.play()
            if creation.estimatedLoadingTime == 0 {
                let time = Int64.random(in: 4...7)
//                #if DEBUG
//                time = 1
//                #endif
                
                creation.estimatedLoadingTime = 60 * time - 1
            }
            
            counterLabel?.endTime = creation.estimatedLoadingTime + Int64(Date().timeIntervalSince1970)
            
            startTimer()
        }
        else {
            canDragBack(can: true)
            navBackBtn.isHidden = false
            
            loadingAnimationView.isHidden = true
            loadingLabel.isHidden = true
            cardView.isHidden = false
            btnsView.isHidden = false
            loadingAnimationView.stop()
            cardView.bind(creation: creation) {
                
            } startPlayBlock: {
                
            }

            groupView.bind(creation: creation)
            
            if creation.upDown == .unowned {
                upDownView.isHidden = false
            }
            else if creation.upDown == .up {
//                upDownView.isHidden = true
                showUpFinish()
            }
            else {
                upDownView.isHidden = true
            }
        }
    }
}

// MARK: Actions
extension DetailViewController {
    func hiddenGroupList() {
        UIView.animate(withDuration: 0.15, delay: 0,
                       options: .curveEaseOut) {
            self.groupView.top = self.groupViewOriginTop
        }
    }
    
    func showGroupList() {
//        groupView.present(in: view)
        UIView.animate(withDuration: 0.15, delay: 0,
                       options: .curveEaseOut) {
            self.groupView.top = 117
        }
    }
    
    func groupDelete(creation : CreationInfo) {
        AlertHelper.show(title: nil, content: localizedStr("确认删除这个作品吗？"), confirmTitle: localizedStr("确认"), cancelTitle: localizedStr("取消")) {
            self.delete(creation: creation)
        }
    }
    
    func delete(creation : CreationInfo) {
        HUD.showHud()
        let creationId : Int64 = creation.creationId
        let api = AIApi.deleteCreation(creation_id:creationId )
        api.post { [weak self] data, msg in
            HUD.hiddenHud()
//            if let data {
                Toast.showToast(localizedStr("删除成功"))
                LibraryViewDataSource.shared.deleteCreation(creationId: creationId)
                
                Thread.after(seconds: 0.25) {
                    self?.navigationController?.popViewController(animated: true)
                }
//            }
        } failBlock: { error in
            HUD.hiddenHud()
            
        }
        
//        api.post { [weak self] result in
//            HUD.hiddenHud()
//            switch result {
//            case let .success(data):
//                Toast.showToast(localizedStr("删除成功"))
//                LibraryViewDataSource.shared.deleteCreation(creationId: creationId)
//                
//                Thread.after(seconds: 0.25) {
//                    self?.navigationController?.popViewController(animated: true)
//                }
//                
//            case let .failure(e):
//                break
//            }
//        }
    }
    
    @objc func clickBackToHome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func clickShowDetail() {
        let vc = DetailViewController()
//        #if DEBUG
//        creation?.status = .finish
//        #endif
        
        vc.creation = creation
        
        var list = navigationController?.viewControllers ?? []
        list.removeLast()
        list.append(vc)
        navigationController?.setViewControllers(list, animated: true)
    }
    
    @objc func clickDownloadAction() {
        guard let creation = creation else {
            return
        }
        
        ResourceLoader.shared.getItem(url: creation.videoUrl, ext: "mp4") { progres in
            HUD.progress(progres, msg: localizedStr("下载中") + "...")
            debugPrint("download progress : \(progres)")
        } completion: { item, error in
            
            if let e = error {
                HUD.hiddenHud()
                Toast.showToast(e.localizedDescription)
            }
            else if let item = item {
                HUD.showHud(localizedStr("保存中") + "...")
//                ZYAlbumHelper.sharedInstance().saveMideaFilePath(item.filepath, fileName: item.filename, isVideo: true) { result, error in
//                    HUD.hiddenHud()
//                    if result {
//                        Toast.showToast(localizedStr("已保存到相册"))
//                    }
//                    else if let _ = error {
//                        Toast.showToast(localizedStr("保存失败"))
//                    }
//                }
                Utils.saveVideoToAlbum(videoURL: item.fileUrl) { result, msg in
                    HUD.hiddenHud()
                    if result {
                        Toast.showToast(localizedStr("已保存到相册"))
                    }
                    else {
                        Toast.showToast(localizedStr("保存失败"))
                    }
                }
            }
        }
    }
    
    @objc func clickRebuildAction() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func reportUpDownStatus(status : Int) {
        guard let creation = creation else { return }
        let api = AIApi.creationUpDown(creation_id: creation.creationId, status: status)
        api.post { [weak self] data, msg in
            self?.creation?.upDown = CreationInfo.UpDownStatus(rawValue: status) ?? .unowned
            self?.upDownView.isHidden = true
        } failBlock: { error in
            if let msg = error?.localizedDescription {
                Toast.showToast(msg)
            }
        }
    }
    
    @objc func showRebuildAlert() {
        
        let msg = localizedStr("是否要重新制作?")
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let cancel = UIAlertAction(title: localizedStr("取消"), style: .cancel)
        let okTitle = localizedStr("重做") + "(" + "\(creation!.coin_cnt_remake)" + "💎)"
        let ok = UIAlertAction(title: okTitle, style: .default) { [weak self] action in
            self?.retryAction()
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    func retryAction() {
        guard let creation = creation else { return }
        let api = AIApi.creationRemake(creation_id: creation.creationId)
        
        HUD.showHud()
        api.post { [weak self] data, msg in
            HUD.hiddenHud()
            let creationList = data?.arrayDictionaryValueForKey("creation_list")
            if let creationInfo = creationList?.first as? [String : Any] {
                let creation = CreationInfo(info: creationInfo)
                self?.showDetail(creation: creation)
                LibraryViewDataSource.shared.loadData()
            }
            
        } failBlock: { error in
            HUD.hiddenHud()
            if let msg = error?.localizedDescription {
                Toast.showToast(msg)
            }
        }
    }
    
    func showUpAnimation() {
        upDownView.isHidden = true
        
        let upAnimationView : LOTAnimationView = .init(frame: CGRect(x: -120, y: 0, width: 120, height: 120))
        
        let upWidth : CGFloat = 120
        let upTop : CGFloat = upDownView.top - 13
        
        upAnimationView.frame = CGRect(x: (UIScreen.width - upWidth) * 0.5, y: upTop, width: upWidth, height: upWidth)
        
        if let path : String = Bundle.main.path(forResource: "detail_up", ofType: "json") {
            upAnimationView.filePath = (light: path, dark: path)
            upAnimationView.loopAnimationCount = 1
            view.addSubview(upAnimationView)
        }
        
//        upAnimationView.currentFrame = 33
        upAnimationView.play()
    }
    
    func showUpFinish() {
        upDownView.isHidden = true
        
//        let upAnimationView : LOTAnimationView = .init(frame: CGRect(x: -120, y: 0, width: 120, height: 120))
        
        let upAnimationView = UIImageView()
        
        let upWidth : CGFloat = 180
        let upHeight : CGFloat = 120
        let upTop : CGFloat = upDownView.top - 13
        
        upAnimationView.frame = CGRect(x: (UIScreen.width - upWidth) * 0.5, y: upTop, width: upWidth, height: upHeight)
        
        upAnimationView.image = UIImage(named: "detail_up_finished")
        view.addSubview(upAnimationView)
        
//        if let path : String = Bundle.main.path(forResource: "detail_up", ofType: "json") {
//            upAnimationView.filePath = (light: path, dark: path)
//            upAnimationView.loopAnimationCount = 1
//            view.addSubview(upAnimationView)
//        }
        
//        upAnimationView.currentFrame = 33
//        upAnimationView.play()
    }
    
    func showDetail(creation : CreationInfo) {
        var vclist = navigationController?.viewControllers
        vclist?.removeLast()
        let detail = DetailViewController()
        detail.creation = creation
        vclist?.append(detail)
        navigationController?.setViewControllers(vclist ?? [], animated: true)
    }
}

// MARK: Timer
extension DetailViewController {
    
    func endTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer() {
        if let _ = timer {
            endTimer()
        }
        
        let timer = Timer(timeInterval: 1, target: self, selector: #selector(timerFire), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    @objc private func timerFire() {
        let leftTime = counterLabel?.refresh() ?? 0
        if 0 == leftTime % 10 {
            loadDetailInfo()
        }
        
        // 倒计时结束
        if 0 == leftTime {
            endTimer()
            showTimeOut()
        }
        
//        #if DEBUG
//        if 55 == leftTime {
//            endTimer()
//            showFinishAnimation()
//        }
//        else if 57 == leftTime {
//            endTimer()
//            showTimeOut()
//        }
//        
//        #endif
    }
    
    func showTimeOut() {
        Toast.showToast(localizedStr("超时错误提示"))
    }
    
    
    private func loadDetailInfo() {
        guard let creation = creation else{
            return
        }
        
        let api = AIApi.creationDetail(creation_id: creation.creationId)
        api.post { [weak self] data, msg in
            if let data {
                debugPrint(data)
                let creationInfo = data.dictValueForKey("creation_info")
                let creation = CreationInfo(info: creationInfo)
                self?.checkCreation(creation: creation)
            }
        } failBlock: { error in
            debugPrint(error)
        }

//        api.post { [weak self] result in
//            switch result {
//            case let .success(data):
//                debugPrint(data)
//                let creationInfo = data.dictValueForKey("creation_info")
//                let creation = CreationInfo(info: creationInfo)
//                self?.checkCreation(creation: creation)
//            case let .failure(e):
//                debugPrint(e)
//            }
//        }
    }
    
    func checkCreation(creation : CreationInfo) {
        guard let crea = self.creation, crea.creationId == creation.creationId else {
            return
        }
        
        if creation.status == .finish {
            self.creation = creation
            endTimer()
            showFinishAnimation()
        }
    }
    
    func showFinishAnimation() {
        UIView.animate(withDuration: 0.15, delay: 0) {
            self.loadingAnimationView.alpha = 0
            self.loadingTitle.alpha = 0
            self.loadingLabel.alpha = 0
            self.counterLabel?.alpha = 0
            
            self.finishView.alpha = 1
            self.showDetailBtn.alpha = 1
        } completion: { result in
            self.loadingAnimationView.stop()
        }
    }
    
}


extension DetailViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true)
        
        canDragBack(can: true)
        
        let vc = CreationViewControllerV2()
        vc.imageStart = image
        vc.prompt = creation?.text
        vc.is5sec = (creation?.dur ?? 5) == 5
        vc.isHigh = ((creation?.mode_option ?? "normal") != "normal")
        
        var vclist = navigationController?.viewControllers ?? []
        vclist.removeLast()
        vclist.append(vc)
        navigationController?.setViewControllers(vclist, animated: true)
    }
}

extension DetailViewController : UINavigationControllerDelegate {
    
}



