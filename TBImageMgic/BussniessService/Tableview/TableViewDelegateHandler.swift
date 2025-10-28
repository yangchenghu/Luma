
import UIKit
import Foundation

class TableViewDelegateHandler : NSObject, UITableViewDataSource, UITableViewDelegate {

    weak var tableView : UITableView?
    
    var list : [ BaseCellViewModel ] = []

    func bindTableView(tableView: UITableView) {
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func bindList(list : [BaseCellViewModel]) {
        debugPrint("--- bind list :\(list.count)")
        self.list = list
        self.tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item : BaseCellViewModel = list[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier, for: indexPath) as? BaseTableViewCell else {
            return UITableViewCell()
        }
       
        cell.bindViewModel(viewModel: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item : BaseCellViewModel = list[indexPath.row]
        return item.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item : BaseCellViewModel = list[indexPath.row]
        item.clickBlock?()
    }
    
}

