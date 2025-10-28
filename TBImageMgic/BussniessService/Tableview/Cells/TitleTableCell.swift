
import UIKit
import Foundation

class TitleTableCellViewModel : BaseCellViewModel {
    var title : String = ""
    var titleRect : CGRect = .zero
    var arrowRect : CGRect = .zero
    
    var backgroundColor : UIColor = .clear
    
    init(title: String) {
        super.init()
        
        identifier = "TitleTableViewModel"
        cellIdentifier = "TitleTableCell"
        
        cellHeight = 52
        self.title = title
        
        titleRect = CGRect(x: 18, y: 15, width: 150, height: 22)
        arrowRect = CGRect(x: UIScreen.width - 18 - 24, y: (52 - 24) * 0.5, width: 24, height: 24)
    }
}

class TitleTableCell : BaseTableViewCell {
    
    var titleLabel : UILabel = UILabel()
    var arrowImage : UIImageView = UIImageView()
    var viewModel : TitleTableCellViewModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
        
        arrowImage.image = UIImage(named: "ic_tableview_title_cell_arrow")
        contentView.addSubview(arrowImage)
        
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindViewModel(viewModel: BaseCellViewModel) {
        guard let vm = viewModel as? TitleTableCellViewModel else {
            return
        }
        
        self.viewModel = vm
        backgroundColor = vm.backgroundColor
        contentView.backgroundColor = vm.backgroundColor
        
        titleLabel.text = vm.title
        titleLabel.frame = vm.titleRect
        arrowImage.frame = vm.arrowRect
    }
    
    
    
    
}

