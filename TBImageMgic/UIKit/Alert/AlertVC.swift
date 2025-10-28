
import Foundation
import UIKit

class AlertVC: BaseVC {
    var titleInfo: String? {
        didSet {
            if let titleInfo = titleInfo {
                titleLabel.text = titleInfo
                titleLabel.isHidden = false
            } else {
                titleLabel.isHidden = true
            }
        }
    }
    
    var contentInfo: String = "" {
        didSet {
            contentLabel.text = contentInfo
            if isViewLoaded {
                refreshUI()
            }
        }
    }
    var doneText: String = "确定" {
        didSet {
            doneBtn.setTitle(doneText, for: .normal)
//            doneBtn.title = doneText
        }
    }
    var cancelText: String = "取消" {
        didSet {
            cancelBtn.setTitle(cancelText, for: .normal)
        }
    }
    
    var cancelAction: (() -> Void)? {
        didSet {
            cancelBtn.clickBlock = { [weak self] in
                guard let sself = self else { return }
                sself.dismiss(animated: false, completion: nil)
                sself.cancelAction?()
            }
        }
    }
    var doneAction: (() -> Void)? {
        didSet {
//            doneBtn.clickBlock = { [weak self] in
            doneBtn.tapBlock = { [weak self] in
                guard let sself = self else { return }
                sself.dismiss(animated: false, completion: nil)
                sself.doneAction?()
            }
        }
    }
    
    var hasCancel = true {
        didSet {
            cancelBtn.isHidden = !hasCancel
        }
    }
    
    var clickBackDismiss = false
    var backDismissBlock : (() -> Void)?
    
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let cancelBtn = UIButton()
    private let doneBtn = UIButton(type: .custom)
    
    override init() {
        super.init()
        showHeaderView = false
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        contentView.backgroundColor = UIColor(hexString: "#191420")
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = true
        view.addSubview(contentView)
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textAlignment = .center
        if let titleInfo = titleInfo {
            titleLabel.text = titleInfo
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
        contentView.addSubview(titleLabel)
        
        contentLabel.textColor = .white.withAlphaComponent(0.75)
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.text = contentInfo
        contentView.addSubview(contentLabel)
        
        cancelBtn.layer.cornerRadius = 22
        cancelBtn.layer.backgroundColor = UIColor.white.withAlphaComponent(0.15).cgColor
        cancelBtn.layer.masksToBounds = true
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelBtn.setTitle(cancelText, for: .normal)
        contentView.addSubview(cancelBtn)
        
        doneBtn.backgroundColor = UIColor(hexString: "#6A74F7")
        doneBtn.layer.cornerRadius = 20
        doneBtn.layer.masksToBounds = true
        doneBtn.setTitleColor(.white, for: .normal)
        doneBtn.setTitleColor(.white.withAlphaComponent(0.5), for: .highlighted)
        doneBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneBtn.setTitle(doneText, for: .normal)
        contentView.addSubview(doneBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshUI()
    }
    
    private func refreshUI() {
        let contentWidth: CGFloat = 300
        let maxContentWidth : CGFloat = contentWidth - 40
        
        var textHeight : CGFloat = 0
        if !(contentLabel.text?.isEmpty ?? true) {
            textHeight = ceil(contentLabel.sizeThatFits(CGSize(width: maxContentWidth, height: 1000)).height)
            textHeight = max(textHeight, 24)
        }
        
        var contentHeight: CGFloat = 158
        
        if titleLabel.isHidden {
            contentHeight = 36 + textHeight + 98
            contentView.frame = CGRect(x: (view.bounds.width - 300) / 2.0, y: (view.bounds.height - contentHeight) / 2.0, width: 300, height: contentHeight)
            titleLabel.frame = .zero
            contentLabel.frame = CGRect(x: 20, y: 36, width: contentWidth - 40, height: textHeight)
        }
        else {
            let top : CGFloat = 30
            let titleHeight : CGFloat = 27
            let titleToContent : CGFloat = 16
            
            contentHeight = top + titleHeight + ( textHeight > 0 ?  titleToContent + textHeight : 0 ) + 98
            
            contentView.frame = CGRect(x: (view.bounds.width - 300) / 2.0, y: (view.bounds.height - contentHeight) / 2.0, width: 300, height: contentHeight)
            
            titleLabel.frame = CGRect(x: 10, y: top, width: contentWidth - 20, height: titleHeight)
            
            if textHeight > 0 {
                contentLabel.frame = CGRect(x: 20, y: titleLabel.frame.maxY + titleToContent, width: contentWidth - 40, height: textHeight)
            }
            else {
                contentLabel.frame = .zero
            }
        }
        
        if hasCancel {
            cancelBtn.frame = CGRect(x: 24, y: contentHeight - 24 - 40, width: 116, height: 44)
            doneBtn.frame = CGRect(x: 160, y: contentHeight - 24 - 40, width: 116, height: 44)
        }
        else {
            doneBtn.frame = CGRect(x: 24, y: contentHeight - 24 - 40, width: contentView.frame.width - 48, height: 44)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard clickBackDismiss else {
            return
        }
        
        
        guard let touch : UITouch = Array(touches).last else {
            return
        }
        
        // 点击了contentview，不响应关闭
        
        let inContentView : Bool? = touch.view?.isDescendant(of: self.contentView)
        
        if let isInContent = inContentView, isInContent {
            return
        }
        
        clickBackDismiss = false
        dismissAnimation()
        backDismissBlock?()
    }
    
    private func dismissAnimation() {
        UIView.animate(withDuration: 0.15) {
            self.contentView.alpha = 0.0
            self.view.alpha = 0.0
        } completion: { [weak self] result in
            if result {
                self?.dismiss(animated: false, completion: nil)
            }
        }
    }
}
