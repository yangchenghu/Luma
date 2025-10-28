//
//  CreationViewController.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/13.
//

import UIKit
import Foundation

class TempCreationViewController : BaseVC {
    
    var creation : CreationInfo?
    var currentIndex : Int = 0
    var creationList : [CreationInfo] = []
    var cardView : CreationCardView = CreationCardView()
    let animationView : LOTAnimationView = LOTAnimationView()
    let makingMaskView : UIView = UIView()
    
    let createBtn : UIButton = UIButton(type: .custom)
    var groupViewOriginTop : CGFloat = 0
    var groupView : DetailGroupCreationListView!
    
//    let collectionView : UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 6
//        layout.minimumInteritemSpacing = 6
//        layout.itemSize = CGSize(width: 101, height: 137)
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//        
//        let collecton = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collecton.showsHorizontalScrollIndicator = false
//        collecton.showsVerticalScrollIndicator = false
//        return collecton
//    }()
    let scrollView : UIScrollView = UIScrollView()
    
    override init() {
        super.init()
        
        self.showBgImage = true
        self.showHeaderView = true
        self.showHeaderBlur = true
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
extension TempCreationViewController {
    
    func setupNav() {
        navHeaderView.backgroundColor = .clear
        changeBlurAlpha(alpha: 0)
    }
    
    func setupView() {
        let navHeight : CGFloat = 0
        // UIScreen.statusBarHeight + UIScreen.navBarHeight
        scrollView.frame = CGRect(x: 0, y: navHeight, width: UIScreen.width, height: UIScreen.height - navHeight - UIScreen.bottomSafeHeight)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        let imgCTop : CGFloat = UIScreen.topHeight + 20
        let imgCLeft : CGFloat = 50
        let imgCRight : CGFloat = 50
        let imgCWidth : CGFloat = UIScreen.width - imgCLeft - imgCRight
        let imgCHeight : CGFloat = ceil(imgCWidth * 1.255)
        
        cardView.frame = CGRect(x: imgCLeft, y: imgCTop, width: imgCWidth, height: imgCHeight)
        cardView.backgroundColor = UIColor(hexString: "#161A28")?.withAlphaComponent(0.53)
        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = true
        cardView.layer.borderWidth = 0.5
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        scrollView.addSubview(cardView)
        
        makingMaskView.frame = cardView.bounds
        makingMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        animationView.loopAnimationCount = -1
        makingMaskView.addSubview(animationView)
         
        cardView.addSubview(makingMaskView)
        makingMaskView.isHidden = true
        
        var top : CGFloat = cardView.bottom + 20
        var btnsLeft : CGFloat = ceil( (UIScreen.width - 140) * 0.5 )
        
        let btnsView = TwoButtonsView(frame: CGRect(x: btnsLeft, y: top, width: 140, height: 38))
        btnsView.selectedIndexBlock = { [weak self] index in
            let player = self?.cardView.player
            player?.isHidden = ( 0 != index)
        }
        scrollView.addSubview(btnsView)
        top += btnsView.height
        top += 40
        
        let leftMargin : CGFloat = 20.0
        let rightMargin : CGFloat = 20.0
        let contentWidth : CGFloat = UIScreen.width - leftMargin - rightMargin
        
        createBtn.frame = CGRect(x: leftMargin, y: top, width: contentWidth, height: 56)
        createBtn.backgroundColor = UIColor(hexString: "#6F72F6")
        createBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        createBtn.setTitleColor(.white, for: .normal)
        createBtn.layer.cornerRadius = 56 * 0.5
        createBtn.layer.masksToBounds = true
        let title : String = currentCreation()?.btnText ?? (localizedStr("我要做同款") + "(\(AccountManager.userInfo.consumeCoins)" + "💎)")
        createBtn.setTitle(title, for: .normal)
        createBtn.addTarget(self, action: #selector(clickCreateAction), for: .touchUpInside)
        scrollView.addSubview(createBtn)
        top += createBtn.height
        top += 37
        
        // 底部漏出64
        let groupHeight : CGFloat = view.height - 117
        groupViewOriginTop = view.height - 64 - UIScreen.bottomSafeHeight
        groupView = DetailGroupCreationListView(frame: CGRect(x: 0, y: groupViewOriginTop, width: UIScreen.width, height: groupHeight), isTemp: true)
        groupView.clickHiddenBlock = { [weak self] in
            self?.hiddenGroupList()
        }
        
        groupView.clickShowBlock = { [weak self] in
            self?.showGroupList()
        }
        
        groupView.clickCreationBlock = { [weak self] creation in
            self?.showCreation(creation: creation)
        }
        
        groupView.clickDeleteBlock = { [weak self] creation in
            self?.groupDelete(creation: creation)
        }
        
        scrollView.addSubview(groupView)

        if top < view.height {
            top = view.height
        }
        
        scrollView.contentSize = CGSize(width: scrollView.width, height: top)
    }
    
    func refreshData() {
        if let creation = self.creation {
            cardView.bind(creation: creation)
            groupView.bind(creation: creation)
        }
    }
    
    func currentCreation() -> CreationInfo? {
        if currentIndex < creationList.count {
            return creationList[currentIndex]
        }
        return nil
    }
}

// action
extension TempCreationViewController {
    
    func hiddenGroupList() {
        UIView.animate(withDuration: 0.15, delay: 0,
                       options: .curveEaseOut) {
            self.groupView.top = self.groupViewOriginTop
        }
    }
    
    func showGroupList() {
        UIView.animate(withDuration: 0.15, delay: 0,
                       options: .curveEaseOut) {
            self.groupView.top = 117
        }
    }
    
    func showCreation(creation : CreationInfo) {
        cardView.bind(creation: creation)
    }
    
    func groupDelete(creation : CreationInfo) {
        AlertHelper.show(title: nil, content: localizedStr("确认删除这个作品吗？"), confirmTitle: localizedStr("确认"), cancelTitle: localizedStr("取消")) {
            self.delete(creation: creation)
        }
    }
    
    func delete(creation : CreationInfo) {
//        HUD.showHud()
//        let api = AIApi.deleteCreation(creation_id: creation.creationId)
//        api.post { result in
//            HUD.hiddenHud()
//            switch result {
//            case let .success(data):
//                Toast.showToast(localizedStr("删除成功"))
//                
//            case let .failure(e):
//                break
//            }
//        }
    }
    
    @objc func clickCreateAction() {
        let vc = CreationViewControllerV2()
        vc.exampleId = creation?.exampleId ?? 0
        navigationController?.pushViewController(vc, animated: true)
        
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        present(picker, animated: true)
        
//        let vc = CreationViewController()
//        vc.exampleId = currentCreation()?.exampleId ?? 0
//        navigationController?.pushViewController(vc, animated: true)
    }
}

extension TempCreationViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        currentIndex = indexPath.row
        refreshData()
    }
    
}

extension TempCreationViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        creationList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TempCreationCollectionCell.self), for: indexPath) as! TempCreationCollectionCell
        if indexPath.row < creationList.count {
            let creation = creationList[indexPath.row]
            cell.bind(creation: creation)
            cell.selectedView.isHidden = (currentIndex != indexPath.row)
        }
        return cell
    }
    
    
}

extension TempCreationViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true)
        
        let vc = CreationViewController()
        vc.image = image
        vc.exampleId = currentCreation()?.exampleId ?? 0
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension TempCreationViewController : UINavigationControllerDelegate {
    
}

extension TempCreationViewController : UIScrollViewDelegate {
    
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
