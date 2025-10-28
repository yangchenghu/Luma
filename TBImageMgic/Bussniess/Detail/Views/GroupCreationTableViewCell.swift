//
//  GroupCreationTableViewCell.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/23.
//

import UIKit
import Foundation

class GroupCreationTableViewCell : UITableViewCell {
    
    var viewModel : CreationInfoViewModel?
    
    let cuttingImage = CuttingImageView()
    let label = UILabel()
    let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func bind(vm : CreationInfoViewModel) {
        viewModel = vm
        
        guard let creation = vm.creation else { return }
        
        cuttingImage.imageView.sd_setImage(with: URL(string: creation.startImgUrl), placeholderImage: nil) {[weak self] img, err, _, url in
            self?.cuttingImage.image = img
        }
        
        label.text = vm.text
        timeLabel.text = vm.timeString
    }
    
}

extension GroupCreationTableViewCell {
    
    func setupViews() {
        cuttingImage.frame = CGRect(x: 16, y: 8, width: 155, height: 95)
        cuttingImage.layer.cornerRadius = 16
        cuttingImage.layer.masksToBounds = true
        contentView.addSubview(cuttingImage)
        
        let labelLeft : CGFloat = 16 + 155 + 14
        label.frame = CGRect(x: labelLeft, y: 8, width: UIScreen.width - labelLeft - 16, height: 70)
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white.withAlphaComponent(0.64)
        label.numberOfLines = 0
        contentView.addSubview(label)
        
        timeLabel.frame = CGRect(x: labelLeft, y: 82, width: UIScreen.width - labelLeft - 16, height: 14)
        timeLabel.font = .systemFont(ofSize: 10)
        timeLabel.textColor = .white.withAlphaComponent(0.64)
        contentView.addSubview(timeLabel)
    }
}

