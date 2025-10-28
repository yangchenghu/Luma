//
//  HomeViewDataSource.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/21.
//

import UIKit
import Foundation

class HomeViewDataSource : NSObject {
    
    var next_cb : String = ""
    var creation_list : [CreationInfoViewModel] = []
    var has_more : Bool = false
    var refreshDataBlock : ((Error?)->Void)?
    
    deinit {
        removeObservers()
    }
    
    override init() {
        super.init()
        addObservers()
    }
    
    @objc func loadData() {
        next_cb = ""
        requestData(isMore: false)
    }
    
    func loadMore() {
        requestData(isMore: true)
    }
}

// observer
extension HomeViewDataSource {
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name("accoount.get.token"), object: nil)
    }
}

// Actions
extension HomeViewDataSource {
    func requestData(isMore : Bool) {
        let api = AIApi.homeShareCreationList(next_cb: next_cb)
        api.post { [weak self] data, message in
            guard let data = data else {
                return
            }
            
            debugPrint("data is:\(data)")
            if !isMore {
                self?.creation_list.removeAll()
            }
            
            self?.handleData(data: data)
            
        } failBlock: { [weak self] e in
            let msg = e?.localizedDescription ?? ""
            debugPrint(msg)
            if let callback = self?.refreshDataBlock {
                callback(e)
            }
        }
    }
    
    func handleData(data : [String : Any]) {
        has_more = data.boolValueForKey("more")
        next_cb = data.stringValueForKey("next_cb")
        
        let list = data.arrayDictionaryValueForKey("creation_list")
        let createList = list.map{ CreationInfo(info: $0) }
        let modelList = createList.map{
            let model = CreationInfoViewModel()
            model.bind(creation: $0)
            model.buildHomePageModel()
            return model
        }
        creation_list = creation_list + modelList
        
        if let callback = refreshDataBlock {
            callback(nil)
        }
    }
    
    public func rebuildModel() {
        creation_list.forEach{
            $0.rebuildTime()
        }
    }
}

