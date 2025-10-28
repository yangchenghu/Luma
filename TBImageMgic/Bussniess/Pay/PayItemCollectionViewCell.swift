//
//  PayItemCollectionViewCell.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/14.
//

import UIKit
import Foundation

class PayItemCollectionViewCell: UICollectionViewCell {
    
    var product : ProductInfo?
    
    let countLabel : UILabel = UILabel()
    let payLabel : UILabel = UILabel()
    let discountImage : UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(product : ProductInfo) {
        self.product = product
        
        let disCount = product.coinDiscount
        if disCount == 16 || disCount == 17 {
            discountImage.image = UIImage(named: "badge_plan__save_16_off")
            countLabel.attributedText = buildCoinText(cnt: product.coinBaseCnt, ext: product.coinExtCnt, extColor: UIColor(hexString: "#65C7A3") ?? .white)
        }
        else if 20 == disCount {
            discountImage.image = UIImage(named: "badge_plan__save_20_off")
            countLabel.attributedText = buildCoinText(cnt: product.coinBaseCnt, ext: product.coinExtCnt, extColor: UIColor(hexString: "#65C7A3") ?? .white)
        }
        else if 25 == disCount {
            discountImage.image = UIImage(named: "badge_plan__save_25_off")
            countLabel.attributedText = buildCoinText(cnt: product.coinBaseCnt, ext: product.coinExtCnt, extColor: UIColor(hexString: "#7B8BF9") ?? .white)
        }
        else if 30 == disCount {
            discountImage.image = UIImage(named: "badge_plan__save_30_off")
            countLabel.attributedText = buildCoinText(cnt: product.coinBaseCnt, ext: product.coinExtCnt, extColor: UIColor(hexString: "#F0B151") ?? .white)
        }
        else {
            discountImage.image = nil
            countLabel.text = "\(product.coinCnt)"
        }
        
        var usd = "\(product.usdCnt)"
        usd.insert(".", at: usd.index(usd.endIndex, offsetBy: -2))
        payLabel.text = "USD $\(usd)"
    }
}

extension PayItemCollectionViewCell {
    
    func setupViews() {
        layer.cornerRadius = 24
        layer.masksToBounds = true
        layer.backgroundColor = UIColor(hexString: "#FFFFFF")?.withAlphaComponent(0.04).cgColor
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(hexString: "#FFFFFF")?.withAlphaComponent(0.1).cgColor
        
        let iconLabel = UILabel(frame: CGRect(x: 40, y: 22, width: self.width - 40 - 40, height: 26))
        iconLabel.textAlignment = .center
        iconLabel.font = .boldSystemFont(ofSize: 26)
        iconLabel.text = "💎"
        addSubview(iconLabel)
        
        let imgLeft : CGFloat = ceil( width * 0.5 )
        discountImage.frame = CGRect(x: imgLeft, y: 0, width: 45, height: 44)
//        discountImage.backgroundColor = .red
        addSubview(discountImage)
        
        countLabel.frame = CGRect(x: 20, y: 58, width:  self.width - 20 - 20, height: 22)
        countLabel.textAlignment = .center
        countLabel.textColor = .white
        countLabel.font = .boldSystemFont(ofSize: 20)
        countLabel.text = "1000"
        addSubview(countLabel)
        
        payLabel.frame = CGRect(x: 16, y: self.height - 11 - 30, width: self.width - 16 - 16, height: 30)
        payLabel.layer.cornerRadius = 15
        payLabel.layer.masksToBounds = true
        payLabel.backgroundColor = UIColor(hexString: "#FFFFFF")?.withAlphaComponent(0.1)
        
        payLabel.textAlignment = .center
        payLabel.textColor = .white
        payLabel.font = .systemFont(ofSize: 14)
        payLabel.text = "1000"
        addSubview(payLabel)
    }
    
    
}


extension PayItemCollectionViewCell {
    
    func buildCoinText( cnt : Int, ext: Int, extColor : UIColor) -> NSAttributedString {
        let whiteTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .paragraphStyle: createCenteredParagraphStyle()
        ]
        
        let extTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: extColor,
            .paragraphStyle: createCenteredParagraphStyle()
        ]
        
        let whiteAttributedString = NSAttributedString(string: "\(cnt)", attributes: whiteTextAttributes)

        let extAttributedString = NSAttributedString(string: "+\(ext)", attributes: extTextAttributes)
        
        // 创建一个可变的 NSMutableAttributedString，并将红色和白色部分合并
        let combinedAttributedString = NSMutableAttributedString()
        combinedAttributedString.append(whiteAttributedString)
        combinedAttributedString.append(extAttributedString)

        return combinedAttributedString
    }
    
    func createCenteredParagraphStyle() -> NSParagraphStyle {
        // 创建段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center // 设置对齐方式为居中
        return paragraphStyle
    }
    
}

