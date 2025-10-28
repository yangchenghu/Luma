//
//  LibraryViewController.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/21.
//

import UIKit
import Foundation
import MJRefresh

class LibraryViewController : BaseVC {
    
    var colltionLayout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var collectionView : UICollectionView?
    let datasource = LibraryViewDataSource.shared
    
    override init() {
        super.init()
        
        self.showCloseView = false
        self.showNavTitle = true
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
        setupData()
        loadData()
    }
    
    override func base_languageChanged() {
        super.base_languageChanged()
          
        guard isViewLoaded else { return }
        
        navTitleLabel.text = localizedStr("资料库")
        
        datasource.rebuildModel()
        collectionView?.reloadData()
    }
    
}

// UI
extension LibraryViewController {
    func setupNav() {
        navHeaderView.backgroundColor = .clear
        navTitleLabel.font = .boldSystemFont(ofSize: 17)
        navTitleLabel.text = localizedStr("资料库")
        changeBlurAlpha(alpha: 0)
    }
    
    func setupView() {
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height - UIScreen.tabbarHeight), collectionViewLayout: colltionLayout)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.backgroundColor = UIColor.clear
        collectionView.decelerationRate = .normal
        collectionView.register(HomeViewCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(HomeViewCollectionViewCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        view.insertSubview(collectionView, belowSubview: navHeaderView)
        
        colltionLayout.minimumInteritemSpacing = 16
        colltionLayout.minimumLineSpacing = 16
        colltionLayout.sectionInset = UIEdgeInsets(top: UIScreen.topHeight + 16, left: 16, bottom: 16, right: 16)
        
        let header = FeedRefreshApngHeader.init { [weak self] in
            self?.loadData()
        }
        collectionView.mj_header = header
        self.collectionView = collectionView
    }
    
    func setupData() {
        datasource.refreshDataBlock = { [weak self] e in
            if let err = e {
                Toast.showToast(err.localizedDescription)
            }
            else {
                self?.collectionView?.mj_header?.endRefreshing()
                self?.collectionView?.reloadData()
            }
        }
    }
    
    func loadData() {
        datasource.loadData()
    }
    
    
}

extension LibraryViewController : UICollectionViewDelegateFlowLayout {
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let list = datasource.creation_list
        if indexPath.row < list.count {
            let creationVm = list[indexPath.row]
            
            if let creation = creationVm.creation, creation.status == .finish {
                let vc = DetailViewController()
                vc.creation = creation
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension LibraryViewController : UICollectionViewDataSource {
    
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

extension LibraryViewController : UIScrollViewDelegate {
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


