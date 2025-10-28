//
//  CreationStyleView.swift
//  TBImageMgic
//
//  Created by wplive on 2024/9/8.
//

import UIKit
import Foundation



class CreationStyleView : UIView {
    
    var dataList : [CreationStyleModel] = []
    var changeStyle : ( (String) -> Void )?
    
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
//        layout.itemSize = CGSize(width: 78, height: 134)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        let collecton = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collecton.showsHorizontalScrollIndicator = false
        collecton.showsVerticalScrollIndicator = false
        collecton.bounces = false
        collecton.backgroundColor = .clear
        return collecton
    }()
    
    var cellSize : CGSize = CGSizeZero
    var viewHeight : CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        handleCellSize()
        setupViews()
        buildData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
    func buildData() {
//        dataList.append(CreationStyleModel(imgName: "default", nameKey: "默认", mode: "default"))
//        
//        dataList.append(CreationStyleModel(imgName: "hug", nameKey: "拥抱", mode: "hug"))
//        
//        dataList.append(CreationStyleModel(imgName: "dance", nameKey: "跳舞", mode: "dance"))
//        
//        dataList.append(CreationStyleModel(imgName: "turnround", nameKey: "转身露出后背", mode: "turnround"))
//        
//        dataList.append(CreationStyleModel(imgName: "spinning", nameKey: "转圈", mode: "spinning"))
//        
//        dataList.append(CreationStyleModel(imgName: "intimatephoto", nameKey: "两个人的亲密合影", mode: "intimatephoto"))
//        
//        dataList.append(CreationStyleModel(imgName: "kiss", nameKey: "接吻", mode: "kiss"))
//        
//        dataList.append(CreationStyleModel(imgName: "funnyaction", nameKey: "搞笑动作", mode: "funnyaction"))
        
        ConfigManager.shared.styleList.forEach { style in
            
//            dataList.append(CreationStyleModel(imgName: "funnyaction", nameKey: "搞笑动作", mode: "funnyaction"))
            dataList.append(CreationStyleModel(videoUrl: style.video_url, nameKey: style.title, promopt: style.prompt))
        }
        
        collectionView.reloadData()
        
        reset()
    }
    
    func reset() {
        guard dataList.count > 0 else { return }
        
        Thread.after(seconds: 0.2) {
            let index = IndexPath(row: 0, section: 0)
            self.collectionView.selectItem(at: index, animated: false, scrollPosition: [])
        }
    }
}

extension CreationStyleView {
    
    func handleCellSize() {
        let lines : Int = ( ConfigManager.shared.styleList.count / 4) + (ConfigManager.shared.styleList.count % 4 != 0 ? 1 : 0 )
        
        let contentWidth : CGFloat = UIScreen.width - 15 - 15
        let spacing: CGFloat = (contentWidth < 340) ? 2 : 6
        let itemWidth: CGFloat = floor((contentWidth - spacing * 4) / 4)
        let itemHeight : CGFloat = 8 + itemWidth + 8 + 32 + 8
        
        cellSize = CGSize(width: itemWidth, height: itemHeight)
        viewHeight = itemHeight * CGFloat(lines)
    }
    
    func setupViews() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CreationStyleCollectionCell.self, forCellWithReuseIdentifier: NSStringFromClass(CreationStyleCollectionCell.self))
        addSubview(collectionView)
    }
    
    
    func layoutViews() {
        
        collectionView.frame = bounds
        
    }
    
}



extension CreationStyleView : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let model = dataList[indexPath.row]
        changeStyle?(model.promopt)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize
    }

}

extension CreationStyleView : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CreationStyleCollectionCell.self), for: indexPath) as! CreationStyleCollectionCell
        
        let model = dataList[indexPath.row]
        cell.bind(model: model)
        
        return cell
    }
    
    
    
    
}




