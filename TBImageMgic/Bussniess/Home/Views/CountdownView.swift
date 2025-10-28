//
//  CountdownView.swift
//  TBImageMgic
//
//  Created by wolive on 2024/7/16.
//

import UIKit
import Foundation


class CountdownView : UIView {
    let imageView : UIImageView = UIImageView()
    let hourLabel : UILabel = UILabel()
    let minLabel : UILabel = UILabel()
    let secLabel : UILabel = UILabel()
    let milSecLabel : UILabel = UILabel()
    
    var endTime : Int64 = 0 {
        didSet {
            refresh()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = CGRect(x: (frame.width - 144) * 0.5, y: (frame.height - 39) * 0.5, width: 144, height: 39)
        imageView.image = UIImage(named: "count_background")
        addSubview(imageView)
        
        let itemWidth : CGFloat = 38
        let itemHeight : CGFloat = 37
        let font : UIFont = .boldSystemFont(ofSize: 23)
        
        hourLabel.frame = CGRect(x: 0, y: 1, width: itemWidth, height: itemHeight)
        hourLabel.textAlignment = .center
        hourLabel.textColor = .white
        hourLabel.font = font
        hourLabel.text = "00"
        imageView.addSubview(hourLabel)
        
        minLabel.frame = CGRect(x: 53.5, y: 1, width: itemWidth, height: itemHeight)
        minLabel.textAlignment = .center
        minLabel.textColor = .white
        minLabel.font = font
        minLabel.text = "00"
        imageView.addSubview(minLabel)
        
        secLabel.frame = CGRect(x: 106.5, y: 1, width: itemWidth, height: itemHeight)
        secLabel.textAlignment = .center
        secLabel.textColor = .white
        secLabel.font = font
        secLabel.text = "58"
        imageView.addSubview(secLabel)
        
//        milSecLabel.frame = CGRect(x: 106.5, y: 1, width: itemWidth, height: itemHeight)
//        milSecLabel.textAlignment = .center
//        milSecLabel.textColor = .white
//        milSecLabel.font = font
//        milSecLabel.text = "03"
//        imageView.addSubview(milSecLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 返回剩余时间
    public func refresh() -> Int64 {
        // 秒
        let now : Int64 = Int64(Date().timeIntervalSince1970)
        var time = endTime - now
        if time < 0 {
            time = 0
        }
        
        let min = time / 60
        let sec = time % 60
        
        minLabel.text = String(format: "%02d", min)
        secLabel.text = String(format: "%02d", sec)
        
        return time
    }
    
    
}
