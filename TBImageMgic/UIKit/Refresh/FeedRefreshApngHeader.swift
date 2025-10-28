//  FeedRefreshApngHeader.swift
//  PPSocial
//
//  Created by supermanmwng on 2021/9/16.
//  Copyright © 2021 XiaoChuan Technology Co.,Ltd. All rights reserved.
//
//         .-"-.
//       _/_-.-_\_
//      / __> <__ \
//     / //  "  \\ \   see no evil...
//    / / \'---'/ \ \
//    \ \_/`"""`\_/ /
//     \           /

import Foundation
import SDWebImage

class FeedRefreshApngHeader: NormalRefreshApngHeader {
    
    override func prepare() {
        super.prepare()
        refreshConfig()
    }
    
    @objc private func refreshConfig() {
        setAnimationImage(name: "refresh_header", ofType: "gif")
    }

}
