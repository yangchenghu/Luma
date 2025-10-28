//
//  TempCreationCollectionCell.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/15.
//

import UIKit
import Foundation

class TempCreationCollectionCell : UICollectionViewCell {
    
    var creation : CreationInfo?
    
    let selectedView : UIView = UIView()
    let cardView : CreationCardView = CreationCardView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(selectedView)
        contentView.addSubview(cardView)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        selectedView.frame = bounds
        selectedView.layer.cornerRadius = 7
        selectedView.layer.masksToBounds = true
        selectedView.layer.borderWidth = 1
        selectedView.layer.borderColor = UIColor.white.cgColor
        
        cardView.frame = CGRect(x: 6, y: 6, width: width - 12, height: height - 12)
        
    }
    
    func bind(creation : CreationInfo) {
        self.creation = creation
        
        cardView.bind(creation: creation)
        
        
    }
    
    
}


