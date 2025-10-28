
import UIKit
import Foundation

class TitleDetailSwitchTableCellViewModel : BaseCellViewModel {
    var title : String = ""
    var titleRect : CGRect = .zero
    
    var detail : String = ""
    var detailRect : CGRect = .zero
    
    var switchValue : Bool = false
    var switchChangeBlock : ((Bool) -> Void )?
    
    var backgroundColor : UIColor = .clear
    var switchCloseAlpha : CGFloat = 1.0
    
    init(title: String, detail : String, isOpen : Bool) {
        super.init()
        
        identifier = "TitleDetailSwitchTableCellViewModel"
        cellIdentifier = "TitleDetailSwitchTableCell"
        
        self.title = title
        self.detail = detail
        
        self.switchValue = isOpen
        
        titleRect = CGRect(x: 18, y: 6, width: 300, height: 22)
        detailRect = CGRect(x: 18, y: 29, width: 300, height: 17)
        
        cellHeight = 64
    }
}

class TitleDetailSwitchTableCell : BaseTableViewCell {
    
    var titleLabel : UILabel = UILabel()
    var detailLabel : UILabel = UILabel()
    var aswitch : UISwitch = UISwitch()
    
    var viewModel : TitleDetailSwitchTableCellViewModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
        
        detailLabel.font = .systemFont(ofSize: 12)
        detailLabel.textColor = .white
        contentView.addSubview(detailLabel)
        
        aswitch.left = UIScreen.width - aswitch.width - 18
        contentView.addSubview(aswitch)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindViewModel(viewModel: BaseCellViewModel) {
        guard let vm = viewModel as? TitleDetailSwitchTableCellViewModel else {
            return
        }
        
        self.viewModel = vm
        backgroundColor = vm.backgroundColor
        contentView.backgroundColor = vm.backgroundColor
        
        titleLabel.text = vm.title
        titleLabel.frame = vm.titleRect
        
        detailLabel.text = vm.detail
        detailLabel.frame = vm.detailRect
        
        aswitch.isOn = vm.switchValue
        
        aswitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        if vm.switchValue {
            aswitch.alpha = 1.0
        }
        else {
            aswitch.alpha = vm.switchCloseAlpha
        }
    }
    
    @objc private func switchChanged(sender : UISwitch) {
        guard let vm = viewModel else {
            return
        }
        let isOpen = sender.isOn
        
        if isOpen {
            aswitch.alpha = 1.0
        }
        else {
            aswitch.alpha = vm.switchCloseAlpha
        }
        
        vm.switchChangeBlock?(sender.isOn)
    }
}

