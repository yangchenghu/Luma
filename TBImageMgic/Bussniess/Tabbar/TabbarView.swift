
import Foundation
import UIKit

protocol TabbarViewDelegate: AnyObject {
    func tabbarViewDidSelect(index: TabbarIndexType)
}

class TabbarView: UIView {
    weak var delegate: TabbarViewDelegate?
    
    private let createImageView = UIImageView()
    private let homeView = TabbarItemView()
    private let createView = TabbarItemView()
    private let libView = TabbarItemView()
    private var itemsList : [TabbarItemView] = []
    private let lineLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hexString: "#1C1C1C")
        
        setupItems()

        addSubview(homeView)
        addSubview(createView)
        addSubview(libView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupItems() {
        
        let normalColor : UIColor = UIColor(hexString: "#7E7E7E") ?? .clear
        let selectedColor : UIColor = UIColor(hexString: "#6576F9") ?? .clear
                
        homeView.type = .home
        homeView.config(text: "首页", normalIcon: UIImage(named: "Icons_tabbar_home_normal"), normalColor: normalColor, selectIcon: UIImage(named: "Icons_tabbar_home_selected"), selectColor: selectedColor)
        homeView.selected = true
        homeView.tapBlock = { [weak self] in
            self?.delegate?.tabbarViewDidSelect(index: .home)
        }
        itemsList.append(homeView)

        createView.type = .create
        createImageView.frame = CGRect(x: (createView.width - 83) * 0.5, y: -16, width: 83, height: 83)
        createImageView.image = UIImage(named: "Icons_tabbar_add")
        createView.addSubview(createImageView)
        
        createView.tapBlock = { [weak self] in
            self?.delegate?.tabbarViewDidSelect(index: .create)
        }
        itemsList.append(createView)
        
        libView.type = .lib
        // 给进去的是key
        libView.config(text: "资料库", normalIcon: UIImage(named: "Icons_tabbar_library_normal"), normalColor: normalColor, selectIcon: UIImage(named: "Icons_tabbar_library_selected"), selectColor: selectedColor)
        libView.selected = false
        libView.tapBlock = { [weak self] in
            self?.delegate?.tabbarViewDidSelect(index: .lib)
        }
        itemsList.append(libView)

        setupItemsFrame()
    }
    
    func setupItemsFrame() {
        let itemCount: CGFloat = CGFloat(itemsList.count)
        let itemWidth: CGFloat = bounds.width / itemCount
        lineLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: UIScreen.lineHeight)
        
        var left : CGFloat = 0
        
        itemsList.forEach { view in
            view.frame = CGRect(x: left, y: 0, width: itemWidth, height: bounds.height)
            left += itemWidth
        }
        
        createImageView.frame = CGRect(x: (createView.width - 83) * 0.5, y: -19, width: 83, height: 83)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupItemsFrame()
    }
    
    func showUnreadCount(count : Int, type : TabbarIndexType) {
        let index : Int = type.rawValue
        guard index < itemsList.count else {
            return
        }
        
        let item : TabbarItemView = itemsList[type.rawValue]
        item.badgeCount = count
    }
    
    func selected(index: TabbarIndexType) {
        itemsList.forEach {
            $0.selected = ($0.type == index )
        }
    }
}
