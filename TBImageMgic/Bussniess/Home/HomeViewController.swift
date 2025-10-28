//
//  HomeViewController.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/11.
//

import UIKit
import Foundation
import FTPopOverMenu

import HWPanModal
import MJRefresh

class HomeViewController : BaseVC {
    
    var heaerView : HomeHeaderView!
    
    var colltionLayout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var collectionView : UICollectionView!
    
    let datasource = HomeViewDataSource()
    
    let languageBtn = UIButton(type: .custom)
    
    
    deinit {
        removeObservers()
    }
    
    override init() {
        super.init()
        
        self.showNavTitle = true
        self.showHeaderView = true
        self.showCloseView = false
        self.showBgImage = true
        self.showHeaderBlur = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        preSetupNav()
        super.viewDidLoad()
        
        setupNav()
        setupView()
        setupData()
        
        addObservers()
    }
    
    override func base_languageChanged() {
        super.base_languageChanged()
        refreshLanguageBtn()
        
        datasource.rebuildModel()
        collectionView.reloadData()
    }
}

// UI
extension HomeViewController {
    func preSetupNav() {
        // 首页高度 98，加10补齐一下。
        navHeaderView.height = navHeaderView.height + 10
        
        let grandLayer = CAGradientLayer()
        grandLayer.frame = navHeaderView.bounds
        let topColor = UIColor.black.withAlphaComponent(0.35)
        let buttomColor = UIColor.clear
        let gradientColors = [topColor.cgColor, buttomColor.cgColor]
        
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        grandLayer.colors = gradientColors
        grandLayer.startPoint = CGPoint(x: 0.5, y: 0)
        grandLayer.endPoint = CGPoint(x: 0.5, y: 1)
        grandLayer.locations = gradientLocations
        
        navHeaderView.layer.addSublayer(grandLayer)
    }
    
    func setupNav() {
        blurView?.frame = navHeaderView.bounds
        
        let btnWidth : CGFloat = 24
        let btnTop : CGFloat = navHeaderView.height - 10 - btnWidth
        let moreBtn = UIButton(frame: CGRect(x: view.width - 20 - btnWidth, y: btnTop, width: btnWidth, height: btnWidth))
        moreBtn.setImage(UIImage(named: "icon_home_nav_more"), for: .normal)
        moreBtn.addTarget(self, action: #selector(clickMoreAction), for: .touchUpInside)
        navHeaderView.addSubview(moreBtn)
        
//        let historyBtn = UIButton(frame: CGRect(x: moreBtn.left - 24 - btnWidth, y: btnTop, width: btnWidth, height: btnWidth))
//        historyBtn.setImage(UIImage(named: "icon_home_nav_history"), for: .normal)
//        historyBtn.addTarget(self, action: #selector(clickHistoryAction), for: .touchUpInside)
//        historyBtn.hitEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
//        navHeaderView.addSubview(historyBtn)
        let btnSpace : CGFloat = 20
        let lBtnWidth : CGFloat = btnWidth + 10
        languageBtn.frame = CGRect(x: moreBtn.left - btnSpace - lBtnWidth, y: btnTop, width: lBtnWidth, height: btnWidth)
        languageBtn.addTarget(self, action: #selector(clickLanguageAction(btn:)), for: .touchUpInside)
        languageBtn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        languageBtn.setTitleColor(.white, for: .normal)
        
        navHeaderView.addSubview(languageBtn)
        
        navTitleLabel.top = navTitleLabel.top + 10
        navTitleLabel.text = "LumaVideo"
        navTitleLabel.font = .boldSystemFont(ofSize: 17)
        
        changeBlurAlpha(alpha: 0)
        
        refreshLanguageBtn()
    }
    
    func setupView() {
        
        let headerWidth : CGFloat = UIScreen.width
        let headerHeight : CGFloat = ceil(headerWidth * 1.45)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height - UIScreen.tabbarHeight), collectionViewLayout: colltionLayout)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.backgroundColor = UIColor.clear
        collectionView.decelerationRate = .normal
        collectionView.register(HomeViewCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(HomeViewCollectionViewCell.self))
               
//        collectionView.backgroundColor = .red
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        heaerView = HomeHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: headerHeight))
        heaerView.tapBlock = { [weak self] in
            self?.clickTopImage()
        }
        collectionView.addSubview(heaerView)
        
        colltionLayout.minimumInteritemSpacing = 16
        colltionLayout.minimumLineSpacing = 16
        colltionLayout.sectionInset = UIEdgeInsets(top: heaerView.height, left: 16, bottom: 16, right: 16)
        
        let header = FeedRefreshApngHeader.init { [weak self] in
            self?.loadData()
        }
//        header.ignoredScrollViewContentInsetTop = tableView.contentInset.top
        collectionView.mj_header = header
     
        let footer = MJRefreshAutoStateFooter { [weak self] in
            self?.loadMoreData()
        }
        
        footer.setTitle("", for: .idle)
        footer.setTitle("", for: .noMoreData)
        collectionView.mj_footer = footer
    }
    
    func refreshLanguageBtn() {
        var langTitle : String = Language.shared.currentLanguageCode()
        langTitle = langTitle + "▼"
        languageBtn.setTitle(langTitle, for: .normal)
    }
}

// action
extension HomeViewController {
    func setupData() {
        datasource.refreshDataBlock = { [weak self] e in
            if let error = e {
                Toast.showToast(error.localizedDescription)
            }
            else {
                self?.refreshData()
            }
        }
    }
    
    func refreshData() {
        collectionView.mj_header?.endRefreshing()
        
        if datasource.has_more {
            collectionView.mj_footer?.endRefreshing()
        }
        else {
            collectionView.mj_footer?.endRefreshingWithNoMoreData()
        }
        
        collectionView.reloadData()
    }
    
    func loadData() {
        datasource.loadData()
    }
    
    func loadMoreData() {
        datasource.loadMore()
    }
    
    @objc func clickLanguageAction(btn : UIButton) {
        let config = FTPopOverMenuConfiguration.default()
        config?.menuWidth = 150
        config?.textAlignment = .center
        config?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        config?.backgroundColor = UIColor(hexString: "#212223")?.withAlphaComponent(0.95)
        config?.separatorColor = UIColor(hexString: "#808080")?.withAlphaComponent(0.55)
        config?.borderWidth = 0
        config?.animationDuration = 0.15
        
        let titlesList : [String] = Language.shared.languageTitls()
        
        FTPopOverMenu.show(forSender: btn, withMenuArray: titlesList, imageArray: [], configuration: config) { index in
            Language.shared.changeLanguage(index: index)
//            self?.refreshLanguageBtn()
        } dismiss: {}
    }
    
    @objc func clickMoreAction(btn : UIButton) {
        let config = FTPopOverMenuConfiguration.default()
        config?.menuWidth = 130
        config?.textAlignment = .center
        config?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        config?.backgroundColor = UIColor(hexString: "#212223")?.withAlphaComponent(0.95)
        config?.separatorColor = UIColor(hexString: "#808080")?.withAlphaComponent(0.55)
        config?.borderWidth = 0
        
        let money = localizedStr("余额") + ":" + "\(AccountManager.userInfo.coinCnt)" + "💎"
        let charge = localizedStr("充值入口")
//        let history = localizedStr("历史记录")
        let connect = localizedStr("联系我们")
        
        FTPopOverMenu.show(forSender: btn, withMenuArray: [money, charge, connect], imageArray: [], configuration: config) { [weak self] index in
            
            if index == 0 {
                self?.showChargeView()
            }
            else if index == 1 {
                self?.showChargeView()
            }
            else if index == 2 {
                self?.clickContactAction()
            }
//            else if index == 2 {
//                self?.clickHistoryAction()
//            }
//            else if index == 3 {
//                self?.clickContactAction()
//            }
            
        } dismiss: {
            
        }
    }
    
    @objc func clickHistoryAction() {
        let vc = HistoryViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChargeView() {
        let vc = PayViewController()
        self.presentPanModal(vc)
    }
    
    func clickContactAction() {
        let email = "mailto:fengliucaizifyz@gmail.com?subject=LumaVideoFeedback&body=\n\n\n\n\n\n\(NetworkUtils.deviceId())"
        if let url = URL(string: email) {
           UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func clickTopImage() {
        guard let tabbar = TabbarViewController.tabbarVC() else { return }
        tabbar.enterCreationVc(imgCount: 1)
    }
    
    
}


// Observer
extension HomeViewController {
    
    func removeObservers() {
//        NotificationCenter.default.removeObserver(self)
    }
    
    func addObservers() {
//        NotificationCenter.default.addObserver(self, selector: #selector(loadTokenFinish), name: NSNotification.Name("accoount.get.token"), object: nil)
        
    }
    
//    @objc func loadTokenFinish() {
//        loadData()
//    }
}

extension HomeViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true)
        
        let vc = CreationViewController()
        vc.image = image
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension HomeViewController : UINavigationControllerDelegate {
    
}

extension HomeViewController : UIScrollViewDelegate {
    
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


extension HomeViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let list = datasource.creation_list

        if indexPath.row < list.count {
            let creation = list[indexPath.row]
            let vc = TempCreationViewController()
            vc.creation = creation.creation
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let list = datasource.creation_list
        if indexPath.row < list.count {
            let item = list[indexPath.row]
            return item.itemSize
        }
        else {
            return CGSizeZero
        }
    }
}

extension HomeViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        datasource.creation_list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(HomeViewCollectionViewCell.self), for: indexPath) as! HomeViewCollectionViewCell
        let list = datasource.creation_list
        if indexPath.row < list.count {
            let creation = list[indexPath.row]
            cell.bind(creation: creation)
        }
        return cell
    }
}


