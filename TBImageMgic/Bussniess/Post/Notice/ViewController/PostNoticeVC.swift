//
//  RecordNoticeVC.swift
//  ZYVoiceLive
//
//  Created by zuiyou on 2023/8/22.
//

import UIKit
import Foundation
import XCLocalExtension


class RecordNoticeVC : BigBaseVC {
    let dataSource : RecordNoticeDataSource = RecordNoticeDataSource()
    let tableView : UITableView = UITableView(frame: .zero, style: .plain)
    let tableViewHandler : TableViewDelegateHandler = TableViewDelegateHandler()
    
    override init() {
        super.init()
        
        showBgImage = true
        showNavTitle = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavUI()
        setupMainUI()
        loadData(delay: 0)
        addObservers()
        
        
    }
    
}

extension RecordNoticeVC {
    private func setupNavUI() {
        navTitleLabel.text = "互动消息"
        
    }
    
    private func setupMainUI() {
        
        
        
    }
    
    
}

extension RecordNoticeVC {
    
    
    
}


