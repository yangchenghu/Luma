//
//  CreationBaseViewController.swift
//  TBImageMgic
//
//  Created by wplive on 2024/8/22.
//

import UIKit
import Foundation

class CreationBaseViewController : BaseVC {
    
    override init() {
        super.init()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func clickCreateAction() {
        
        
    }
    
    public func charge() {
        let vc = PayViewController()
        vc.paySuccessBlock = { [weak self] in
            HUD.showHud()
            Thread.doInMainThread {
                self?.clickCreateAction()
            }
        }
        
        self.presentPanModal(vc)
    }
    
    public func enterDetail(creation : CreationInfo) {
        Reporter.shared.report(event: .create_finish)
        let vc = DetailViewController()
        vc.creation = creation
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

