//
//  PayViewController.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/13.
//

import UIKit
import Foundation
import HWPanModal
import StoreKit

class PayViewController : BaseVC {
    
    var asset: AssetsInfo? = nil
    
    let coinsLabel : UILabel = UILabel()
    
    var collectionView : UICollectionView?
    var productList : [ProductInfo] = []
    
    var paySuccessBlock : ( () -> Void )?
    
    override init() {
        super.init()
        self.showHeaderView = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNav()
        setupViews()
        loadData()
        
        if PayManager.shared.productsList.count > 0 {
            productList = PayManager.shared.productsList
            refreshData()
        }
    }
    
    
}

// UI
extension PayViewController {
    
    func setupNav() {
        let line = UIView(frame: CGRect(x: (UIScreen.width - 36)*0.5, y: 6, width: 36, height: 5))
        line.backgroundColor = UIColor(hexString: "#7f7f7f")?.withAlphaComponent(0.4)
        line.layer.masksToBounds = true
        line.layer.cornerRadius = 2.5
        view.addSubview(line)
        
        let title = UILabel(frame: CGRect(x: 16, y: 16, width: 100, height: 25))
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.text = localizedStr("Purse")
        title.textColor = UIColor.white
        view.addSubview(title)
        
    }
    
    func setupViews() {
        view.backgroundColor = UIColor(hexString: "#19191A")
        
        let tip = UILabel(frame: CGRect(x: (UIScreen.width - 100) * 0.5, y: 68, width: 100, height: 22))
        tip.textAlignment = .center
        tip.font = .systemFont(ofSize: 14)
        tip.text = "💎" + localizedStr("余额")
        tip.textColor = UIColor(hexString: "#FFFFFF")?.withAlphaComponent(0.4)
        view.addSubview(tip)
        
        coinsLabel.frame = CGRect(x: (UIScreen.width - 200)*0.5, y: 90, width: 200, height: 64)
        coinsLabel.textAlignment = .center
        coinsLabel.font = .systemFont(ofSize: 42, weight: .bold)
        coinsLabel.textColor = .white
        coinsLabel.text = "\(AccountManager.userInfo.coinCnt)"
        view.addSubview(coinsLabel)
  
        let itemWidth : CGFloat = floor( (UIScreen.width - 12 - 12 - 11) * 0.5 )
        let cHeight : CGFloat = UIScreen.height - UIScreen.statusBarHeight - UIScreen.navBarHeight - 20 - 186 - UIScreen.bottomSafeHeight
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 11
        layout.minimumInteritemSpacing = 11
        layout.sectionInset = UIEdgeInsets(top: 0, left: 11, bottom: 12, right: 11)
        layout.itemSize = CGSize(width: itemWidth, height: 139)
        
        let collecton = UICollectionView(frame: CGRect(x: 0, y: 186, width: UIScreen.width , height: cHeight), collectionViewLayout: layout)
        collecton.delegate = self
        collecton.dataSource = self
        collecton.showsHorizontalScrollIndicator = false
        collecton.showsVerticalScrollIndicator = false
        collecton.register(PayItemCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(PayItemCollectionViewCell.self))
        collecton.backgroundColor = UIColor(hexString: "#19191A")
        view.addSubview(collecton)
        collectionView = collecton
    }
}

extension PayViewController {
    
    func checkReceipt(orderId: Int64, usd : Int, receipt : String, callback :@escaping ((Bool) -> Void)) {
        let api = AIApi.orderFinish(orderId: orderId, receiptData: receipt)
        api.post { [weak self] data, msg in
            if let data {
                debugPrint(data)
                let assetInfo = data.dictValueForKey("assets_info")
                AccountManager.userInfo.update(info: assetInfo)
                
                self?.asset = AccountManager.userInfo
                self?.refreshData()
               
                // 显示评分
                if let showReview = data.boolForKey("hp_toast"), showReview {
                    SKStoreReviewController.requestReview()
                }
                    
                
                HUD.hiddenHud()
                Toast.showToast(localizedStr("充值成功"))
                
                Reporter.shared.report(event: .purchase)
                Reporter.shared.report(event: .revenue, params: ["usd" : "\(usd)"])
                
                callback(true)
            }
        } failBlock: { error in
            let msg = error?.localizedDescription ?? ""
            callback(false)
            debugPrint(msg)
            HUD.hiddenHud()
            Toast.showToast(msg)
        }
    }
    
    func createOrder(product : ProductInfo) {
        HUD.showHud()
        let usd : Int = product.usdCnt
        let api = AIApi.orderCreate(productId: product.productId)
        api.post { [weak self] data, msg in
            if let data {
                debugPrint(data)
                let orderInfo = data.dictValueForKey("order_info")
                let order = OrderInfo(info: orderInfo)
                
                self?.pay(orderId: order.orderId, usd : usd, iosProductId: product.iosProductId)
            }
        } failBlock: { error in
            let msg = error?.localizedDescription ?? ""
            debugPrint(msg)
            Toast.showToast(msg)
            HUD.hiddenHud()
        }
        
//        api.post { [weak self] result in
//            switch result {
//            case let .success(data):
//                debugPrint(data)
//                let orderInfo = data.dictValueForKey("order_info")
//                let order = OrderInfo(info: orderInfo)
//                
//                self?.pay(orderId: order.orderId, usd : usd, iosProductId: product.iosProductId)
//            case let .failure(e):
//                debugPrint(e)
//                Toast.showToast(e.localizedDescription)
//                HUD.hiddenHud()
//            }
//        }
    }
    
    func pay(orderId : Int64, usd : Int,iosProductId : String) {
        PayManager.shared.pay(purchaseProductId: iosProductId) { [weak self] receipt, callback in
            self?.checkReceipt(orderId: orderId, usd: usd, receipt: receipt, callback: callback)
        } completeHandle: { [weak self] result , msg in
            if result {
                Thread.after(seconds: 1) {
                    self?.paySuccessBlock?()
                    self?.dismiss(animated: true)
                }
            }
            else {
                Toast.showToast(msg)
                HUD.hiddenHud()
            }
        }
    }
    
}


extension PayViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = productList[indexPath.row]
        
        createOrder(product: product)
    }
    
    
}


extension PayViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(PayItemCollectionViewCell.self), for: indexPath) as! PayItemCollectionViewCell
        if indexPath.row < productList.count {
            let product = productList[indexPath.row]
            cell.bind(product: product)
        }
        return cell
    }
    
}


// action
extension PayViewController {
    
    func loadData() {
        let api = AIApi.productList_v2
        api.post { [weak self] data, msg in
            if let data {
                debugPrint("data is:\(data)")

                let assetInfo = data.dictValueForKey("assets_info")
                AccountManager.userInfo.update(info: assetInfo)
                
                let list = data.arrayDictionaryValueForKey("product_list")
                let productList = list.map{ ProductInfo(info: $0) }
                
                PayManager.shared.productsList = productList
                self?.productList = productList
                
                self?.refreshData()
            }
        } failBlock: { error in
            let msg = error?.localizedDescription ?? ""
            debugPrint(msg)
        }
    }
    
    func refreshData() {
        coinsLabel.text = "\(AccountManager.userInfo.coinCnt)"
        collectionView?.reloadData()
        panModalSetNeedsLayoutUpdate()
    }
    
}


extension PayViewController {
    
    override func longFormHeight() -> PanModalHeight {
        return PanModalHeightMake(.topInset, 44)
    }
    
    override func showDragIndicator() -> Bool {
        return false
    }
        
    override func panScrollable() -> UIScrollView? {
        collectionView
    }
    
}

