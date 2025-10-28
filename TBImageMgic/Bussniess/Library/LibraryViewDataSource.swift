//
//  LibraryViewDataSource.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/21.
//


import Foundation

class LibraryViewDataSource : NSObject {
    
    static let shared = LibraryViewDataSource()
    
    var next_cb : String = ""
    var creation_list : [CreationInfoViewModel] = []
    var has_more : Bool = false
    var refreshDataBlock : ((Error?)->Void)?
    
    //
    var inPrgogressCreationIdList : [Int64] = []
    var timer : Timer?
    
    
    override init() {
        super.init()
    }
    
    func loadMore() {
        
    }
    
    func deleteCreation(creationId : Int64) {
        var creationVM : CreationInfoViewModel? = nil
        creation_list.forEach {
            if let crat = $0.creation, crat.creationId == creationId {
                creationVM = $0
            }
        }
        
        if let creat = creationVM {
            creation_list.remove(creat)
            refreshDataBlock?(nil)
        }
    }
    
}

extension LibraryViewDataSource {
    func loadData() {
        let api = AIApi.getMyCreations
        api.post { [weak self] data, msg in
            if let data {
                debugPrint("data is:\(data)")
                self?.creation_list.removeAll()
                self?.handleData(data: data)
            }
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
        let createList = list.map { CreationInfo(info: $0) }
        let modelList = createList.map {
            
            if $0.status == .inProgress, !self.inPrgogressCreationIdList.contains($0.creationId) {
                self.inPrgogressCreationIdList.append($0.creationId)
            }
            
            let model = CreationInfoViewModel()
            model.bind(creation: $0)
            model.buildLibraryPageModel()
            return model
        }
        creation_list = creation_list + modelList
        
        if let callback = refreshDataBlock {
            callback(nil)
        }
        
        if timer == nil, inPrgogressCreationIdList.count > 0 {
            startTimer()
        }
    }
}

extension LibraryViewDataSource {
    func endTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer() {
        if let _ = timer {
            endTimer()
        }
        
        let timer = Timer(timeInterval: 10, target: self, selector: #selector(timerFire), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
        
        // 手动触发一次
        loadCreationInfo()
    }
    
    @objc private func timerFire() {
        loadCreationInfo()
    }
    
    
    func loadCreationInfo() {
        guard 0 != self.inPrgogressCreationIdList.count else {
            endTimer()
            return
        }
        
        debugPrint("[library] load progress list:\(inPrgogressCreationIdList)")
        
        let api = AIApi.creationsInfo(list: self.inPrgogressCreationIdList)
        api.post { [weak self] data, msg in
            if let data {
                self?.handleLoadInfoData(data: data)
            }
        } failBlock: { error in
            
        }
    }
    
    func handleLoadInfoData(data : [String : Any]) {
        let list = data.arrayDictionaryValueForKey("creation_list")
        let creationList = list.map{
            CreationInfo(info: $0)
        }
        
        var finishCreationList : [CreationInfo] = []
        
        creationList.forEach {
            // 成功，或失败，都需要通知出去
            if $0.status == .finish || $0.status == .fail {
                self.inPrgogressCreationIdList.remove($0.creationId)
                finishCreationList.append($0)
                
                let createion = $0
                let createId = $0.creationId
                creation_list.forEach({
                    if $0.creation?.creationId == createId {
                        $0.bind(creation: createion)
                    }
                })
            }
        }

        if finishCreationList.count > 0 {
            NotificationCenter.default.post(name: .Creation.stausChanged, object: finishCreationList)
//            loadData()
            refreshDataBlock?(nil)
        }
    }
    
    public func rebuildModel() {
        creation_list.forEach{
            $0.rebuildTime()
        }
    }
    
    
}
