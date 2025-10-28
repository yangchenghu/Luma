
import UIKit
import Foundation

protocol BaseTableViewCellProtocol {
    
    func bindViewModel(viewModel : BaseCellViewModel)    
}

class BaseTableViewCell : UITableViewCell, BaseTableViewCellProtocol {
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(viewModel: BaseCellViewModel) {
        fatalError("bindViewModel(coder:) has not been implemented")
    }
}

