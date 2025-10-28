//
//  DetailGroupCreationListView.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/23.
//


import UIKit
import Foundation
import HWPanModal

class DetailGroupCreationListView : UIView {
    
    var isTemp : Bool = true
    var creation : CreationInfo?
    var viewModelList : [CreationInfoViewModel] = []
    
    var blurView : UIVisualEffectView?
    var titleLabel : UILabel = UILabel()
    var timeLabel : UILabel = UILabel()
    var showBtn : UIButton = UIButton(type: .custom)
    var closeBtn : UIButton = UIButton(type: .custom)
    var navLine : UIView = UIView()
    
    var tableView : UITableView = UITableView()
    var deleteBtn : UIButton = UIButton(type: .custom)
    
    var clickHiddenBlock : (() -> Void)?
    var clickShowBlock: (() -> Void)?
    var clickCreationBlock : ((CreationInfo) -> Void)?
    var clickDeleteBlock : ((CreationInfo) -> Void)?
    
    init(frame: CGRect, isTemp: Bool = true) {
        self.isTemp = isTemp
        super.init(frame: frame)
        baseSetup()
        setupNav()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(creation : CreationInfo) {
        self.creation = creation
        
        titleLabel.text = localizedStr("Created by") + "@" + creation.userName
        timeLabel.text = localizedStr("on") + readableTime(creation.createTime)
        
        if isTemp {
            loadDidData()
        }
        else {
            loadGroupData()
        }
    }
    
    func loadGroupData() {
        guard let creation = self.creation else {
            return
        }
        
        let api = AIApi.creationList(group_id: creation.creationGroupId)
        api.post { [weak self] data, msg in
            if let data {
                self?.buildModels(data: data)
            }
            
        } failBlock: { error in
            
        }

//        api.post { [weak self] result in
//            switch result {
//            case let .success(data):
//                self?.buildModels(data: data)
//            case let .failure(e):
//                break
//            }
//        }
    }
    
    func loadDidData() {
        guard let creation = self.creation else {
            return
        }
        
        let api = AIApi.shareCreationList(user_did: creation.deviceId)
        api.post { [weak self] data, msg in
            if let data {
                self?.buildModels(data: data)
            }
            
        } failBlock: { error in
            
        }

//        api.post { [weak self] result in
//            switch result {
//            case let .success(data):
//                self?.buildModels(data: data)
//            case let .failure(e):
//                break
//            }
//        }
    }
}

// UI
extension DetailGroupCreationListView {
    
    func baseSetup() {
        let blur = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blur)
        effectView.frame = bounds
        addSubview(effectView)
        blurView = effectView
    }
    
    func setupNav() {
        let line = UIView(frame: CGRect(x: (UIScreen.width - 36)*0.5, y: 6, width: 36, height: 5))
        line.backgroundColor = UIColor(hexString: "#7f7f7f")?.withAlphaComponent(0.4)
        line.layer.masksToBounds = true
        line.layer.cornerRadius = 2.5
        addSubview(line)
        
        let labelWidth : CGFloat = UIScreen.width - 16 - 46
        titleLabel.frame = CGRect(x: 16, y: 14, width: labelWidth, height: 30)
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
//        titleLabel.text = localizedStr("Purse")
        titleLabel.textColor = UIColor.white
        addSubview(titleLabel)
        
        timeLabel.frame = CGRect(x: 16, y: 42, width: labelWidth, height: 18)
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = .white.withAlphaComponent(0.64)
        addSubview(timeLabel)
        
        
        showBtn.frame = CGRect(x: UIScreen.width - 30 - 16, y: 24, width: 30, height: 30)
//        showBtn.backgroundColor = UIColor(hexString: "#333333")
//        showBtn.layer.cornerRadius = 15
//        showBtn.layer.masksToBounds = true
        let showImg : UIImage? = UIImage(named: "Icons_Createdby_arrow_up")
        // UIImage(systemName: "arrow.down.left.and.arrow.up.right")?.withTintColor(UIColor(hexString: "#828282") ?? .clear, renderingMode: .alwaysOriginal)
        showBtn.setImage( showImg, for: .normal)
        showBtn.addTarget(self, action: #selector(clickShowAction), for: .touchUpInside)
        addSubview(showBtn)
        
        
        closeBtn.frame = CGRect(x: UIScreen.width - 30 - 16, y: 24, width: 30, height: 30)
//        closeBtn.backgroundColor = UIColor(hexString: "#6A74F7")
//        closeBtn.layer.cornerRadius = 15
//        closeBtn.layer.masksToBounds = true
        let closeImg : UIImage? = UIImage(named: "Icons_Createdby_arrow_down")
        // UIImage(systemName: "arrow.up.forward.and.arrow.down.backward")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        closeBtn.setImage(closeImg, for: .normal)
        closeBtn.addTarget(self, action: #selector(clickCancelAction), for: .touchUpInside)
        addSubview(closeBtn)
        closeBtn.isHidden = true
        
        navLine.frame = CGRect(x: 0, y: 76, width: UIScreen.width, height: 0.5)
        navLine.backgroundColor = UIColor(hexString: "#333333")
        addSubview(navLine)
    }
    
    func setupViews() {
        
        var top : CGFloat = 76 + 16
        let leftMargin : CGFloat = 16
        let rightMargin : CGFloat = 16
        let contentWidth : CGFloat = UIScreen.width - leftMargin - rightMargin
        
        let iconImageView : UIImageView = UIImageView(frame: CGRect(x: leftMargin + 3, y: top + 4, width: 21, height: 20))
        iconImageView.image = UIImage(named: "rectangle.stack.badge.play.fill")
        addSubview(iconImageView)
        
        let titleLabel = UILabel(frame: CGRect(x: leftMargin + 30, y: top, width: contentWidth - 28, height: 28))
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.text = localizedStr("Video Renders")
        addSubview(titleLabel)
        
        top += titleLabel.height
        top += 8
        
        let deleteBtnTop : CGFloat = self.height - UIScreen.bottomSafeHeight - 8 - (isTemp ? 0 : 38)
        
        tableView.frame = CGRect(x: 0, y: top, width: UIScreen.width, height: deleteBtnTop - top - 16)
        tableView.backgroundColor = .clear
        tableView.register(GroupCreationTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(GroupCreationTableViewCell.self))
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        
        addSubview(tableView)
        
        if !isTemp {
            deleteBtn.frame = CGRect(x: 50, y: deleteBtnTop, width: UIScreen.width - 100, height: 38)
            deleteBtn.setTitleColor(.red, for: .normal)
            deleteBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
            deleteBtn.setTitle(localizedStr("删除视频"), for: .normal)
            deleteBtn.addTarget(self, action: #selector(clickDeleteAction(creation:)), for: .touchUpInside)
            addSubview(deleteBtn)
        }
    }

}

// actions
extension DetailGroupCreationListView {
    
    @objc func clickShowAction() {
        clickShowBlock?()
        showBtn.isHidden = true
        closeBtn.isHidden = false
        Utils.impactFeedback(level: .light)
    }
    
    @objc func clickCancelAction() {
        clickHiddenBlock?()
        showBtn.isHidden = false
        closeBtn.isHidden = true
    }
    
    @objc func clickDeleteAction(creation : CreationInfo) {
        guard let creation = self.creation else {
            return
        }
        
        clickDeleteBlock?(creation)
    }
    
}

// utils
extension DetailGroupCreationListView {
    
    func buildModels(data : [String : Any]) {
        let list = data.arrayDictionaryValueForKey("creation_list")
        let creationList = list.map{ CreationInfo(info: $0) }
        let vmList = creationList.map {
            let vm = CreationInfoViewModel()
            vm.bind(creation: $0)
            vm.buildGroupPageModel()
            return vm
        }
        
        viewModelList = vmList
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    func readableTime(_ time: Int64) -> String {
        let thatDate = Date(timeIntervalSince1970: TimeInterval(time))
        let formate = DateFormatter()
        formate.dateFormat = "MMM dd, yyyy"
        return formate.string(from: thatDate)
    }
}

extension DetailGroupCreationListView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModelList.count > indexPath.row {
            let vm = viewModelList[indexPath.row]
            if let create = vm.creation {
                self.creation = create
                clickCreationBlock?(create)
                
                clickCancelAction()
                debugPrint("[group] click creation is:\(create.creationId)")
            }
        }
    }
}

extension DetailGroupCreationListView : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        95 + 16
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(GroupCreationTableViewCell.self), for: indexPath) as? GroupCreationTableViewCell else {
            return UITableViewCell()
        }
        if viewModelList.count > indexPath.row {
            let vm = viewModelList[indexPath.row]
            cell.bind(vm: vm)
        }
        return cell
    }
    
}



//extension DetailGroupCreationListView {
//    
//    override func backgroundConfig() -> HWBackgroundConfig {
////        let config = HWBackgroundConfig(behavior: .customBlurEffect)
//        let config = HWBackgroundConfig(behavior: .default)
//        config.backgroundAlpha = 0.0
//        return config
//    }
//    
//    override func showDragIndicator() -> Bool {
//        false
//    }
//    
//    override func longFormHeight() -> PanModalHeight {
//        return PanModalHeightMake(.topInset, 117)
//    }
//    
//    override func shortFormHeight () -> PanModalHeight {
//        return PanModalHeightMake(.content, 50)
//    }
//    
//    override func originPresentationState() -> PresentationState {
//        .long
//    }
//    
//    override func allowsTapBackgroundToDismiss() -> Bool {
//        false
//    }
//    
//    override func allowsDragToDismiss() -> Bool {
//        false
//    }
//    
//    override func didChangeTransition(to state: PresentationState) {
//        
//        
//        
//    }
//    
//    
//}




