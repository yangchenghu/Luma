//
//  HistoryViewController.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/13.
//

import UIKit
import Foundation

class HistoryViewController : BaseVC {
    
    let tableView : UITableView = UITableView()
    
    var creationList : [CreationInfo] = []
    var finishCount : Int = 0
    var isPlayingCell : CreationTableViewCell?
    
    override init() {
        super.init()
        
        self.showNavTitle = true
        self.showBgImage = true
        self.showHeaderView = true
        self.showHeaderBlur = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupView()
        loadData()
    }
}

// UI
extension HistoryViewController {
    
    func setupNav() {
        navHeaderView.backgroundColor = .clear
        navTitleLabel.font = .boldSystemFont(ofSize: 17)
        navTitleLabel.text = localizedStr("历史记录")
        changeBlurAlpha(alpha: 0)
    }
    
    func setupView() {
        let top : CGFloat = 0
        let height = UIScreen.height - top - UIScreen.bottomSafeHeight
        tableView.frame = CGRect(x: 0, y: top, width: UIScreen.width, height: height)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(CreationTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(CreationTableViewCell.self))
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.topHeight))
        
        // TODO: 空页面
//        tableView.noDataView?.title = localizedStr("暂无生成内容")
        
        view.addSubview(tableView)
    }
}

extension HistoryViewController {
    func loadData() {
        let api = AIApi.getMyCreations
        api.post { [weak self] data, msg in
            if let data {
                debugPrint(data)
                let list = data.arrayDictionaryValueForKey("creation_list")
                let cList = list.map{ CreationInfo(info: $0) }
                self?.creationList = cList
                self?.refreshData()
            }
        } failBlock: { error in
            let msg = error?.localizedDescription ?? ""
            debugPrint(msg)
            Toast.showToast(msg)
        }

//        api.post { [weak self] result in
//            switch result {
//            case let .success(data):
//                debugPrint(data)
//                let list = data.arrayDictionaryValueForKey("creation_list")
//                let cList = list.map{ CreationInfo(info: $0) }
//                self?.creationList = cList
//                self?.refreshData()
//            case let .failure(e):
//                debugPrint(e)
//                Toast.showToast(e.localizedDescription)
//                
//            }
//        }
    }
    
    func refreshData() {
        finishCount = 0
        creationList.forEach {
            if $0.status == .finish {
                finishCount += 1
            }
        }
        
        tableView.reloadData()
        
        if creationList.count == 0 {
//            tableView.dataStatus = .noData
        }
        else {
//            tableView.dataStatus = .normal
        }
        
        
//        Thread.after(seconds: 0.1) { [weak self] in
//            self?.checkPlayCell()
//        }
    }
    
    func checkPlayCell() {
//        guard let visibleCells = tableView.visibleCells as? [CreationTableViewCell] else { return }
//        for cell in visibleCells {
//            if let indexPath = tableView.indexPath(for: cell) {
//                if let creation = cell.creation, creation.status != .finish {
//                    return
//                }
//                    
//                let cellRect = tableView.rectForRow(at: indexPath)
//                let completelyVisible = tableView.bounds.contains(cellRect)
//                if completelyVisible {
//                    // Cell is fully visible
//                    print("Cell at \(indexPath) is fully visible.")
//                    
//                    if let playingCell = isPlayingCell, playingCell == cell {
//                        return
//                    }
//                    
//                    isPlayingCell = cell
//                    cell.playVideo()
//                    
//                } else {
//                    // Cell is not fully visible
//                    print("Cell at \(indexPath) is not fully visible.")
//                    
//                    if let playing = isPlayingCell {
//                        playing.pause()
//                        isPlayingCell = nil
//                    }
//                }
//            }
//        }
    }
}


extension HistoryViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let creation = creationList[indexPath.row]
        let vc = DetailViewController()
        vc.creation = creation
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let navHeight : CGFloat = UIScreen.navBarHeight + UIScreen.statusBarHeight
        
        let yOffset = scrollView.contentOffset.y
        if yOffset < 0 {
            changeBlurAlpha(alpha: 0)
        }
        else {
            let alpha : CGFloat = (yOffset / navHeight) * 2
            changeBlurAlpha(alpha: alpha)
        }
    }
}

extension HistoryViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        creationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CreationTableViewCell.self), for: indexPath) as? CreationTableViewCell else {
            return UITableViewCell()
        }
        if creationList.count > indexPath.row {
            let creation = creationList[indexPath.row]
            cell.bind(creation: creation)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let left : CGFloat = 20.0
        var top : CGFloat = 20.0
        let right : CGFloat = 20;
        let imgWidth : CGFloat = UIScreen.width - left - right
        let labelHeight : CGFloat = 22
        let bottom : CGFloat = 12
        
        top += imgWidth
        top += 12
        top += labelHeight
        top += bottom
        
        return top
    }
}

