//
//  CreationInputAlterViewController.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/21.
//

import UIKit
import Foundation
import HWPanModal

// 输入用户名
class CreationInputNameViewController : UIViewController {
    
    let textfield = UITextField()
    
    var inputText : String?
    var submitPromptBlock : ((String) -> Void )?
    
    deinit {
        removeObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupViews()
        
        addObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textfield.becomeFirstResponder()
    }
}

extension CreationInputNameViewController {
    func setupNav() {
        let line = UIView(frame: CGRect(x: (UIScreen.width - 36)*0.5, y: 6, width: 36, height: 5))
        line.backgroundColor = UIColor(hexString: "#7f7f7f")?.withAlphaComponent(0.4)
        line.layer.masksToBounds = true
        line.layer.cornerRadius = 2.5
        view.addSubview(line)
        
        let title = UILabel(frame: CGRect(x: 16, y: 16, width: 100, height: 24))
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 17, weight: .bold)
        title.text = localizedStr("Your name")
        title.textColor = UIColor.white
        view.addSubview(title)
        
        let closeBtn = UIButton(type: .custom)
        closeBtn.frame = CGRect(x: UIScreen.width - 30 - 16, y: 14, width: 30, height: 30)
        closeBtn.backgroundColor = UIColor(hexString: "#333333")
        closeBtn.layer.cornerRadius = 15
        closeBtn.layer.masksToBounds = true
        closeBtn.setImage(UIImage(systemName: "multiply")?.withTintColor(UIColor(hexString: "#828282") ?? .clear, renderingMode: .alwaysOriginal), for: .normal)
        closeBtn.addTarget(self, action: #selector(clickCancelAction), for: .touchUpInside)
        view.addSubview(closeBtn)
    }
    
    func setupViews() {
        view.backgroundColor = UIColor(hexString: "#19191A")
        
        let leftMargin : CGFloat = 18
        let rightMargin : CGFloat = 18
        let contentWidth : CGFloat = UIScreen.width - leftMargin - rightMargin
        
        let inputBgView = UIView(frame: CGRect(x: leftMargin, y: 63, width: contentWidth - 58, height: 46))
        inputBgView.backgroundColor = UIColor(hexString: "#222222")
        inputBgView.layer.cornerRadius = 10
        inputBgView.layer.masksToBounds = true
        view.addSubview(inputBgView)
                
        textfield.frame = CGRect(x: 5, y: 5, width: contentWidth - 10, height: inputBgView.height - 10)
        textfield.backgroundColor = .clear
        textfield.placeholder = localizedStr("UserName")
        textfield.font = .systemFont(ofSize: 16)
        inputBgView.addSubview(textfield)
        
        textfield.text = inputText
        
        let confirmBtn = UIButton(type: .custom)
        confirmBtn.frame = CGRect(x: UIScreen.width - rightMargin - 52, y: 63, width: 52, height: 46)
        confirmBtn.layer.cornerRadius = 13
        confirmBtn.layer.masksToBounds = true
        confirmBtn.backgroundColor = UIColor(hexString: "#6576F9")
        confirmBtn.setImage(UIImage(systemName: "checkmark")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        confirmBtn.addTarget(self, action: #selector(clickSaveAction), for: .touchUpInside)
        view.addSubview(confirmBtn)
    }
}

// actions
extension CreationInputNameViewController {
    @objc func clickCancelAction() {
        dismiss(animated: true)
    }
    
    @objc func clickSaveAction() {
        submitPromptBlock?(textfield.text ?? "")
        dismiss(animated: false)
    }
}

extension CreationInputNameViewController {
    private func addObservers() {

    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func textViewDidChange() {
        
    }
}

extension CreationInputNameViewController {
    
    override func longFormHeight() -> PanModalHeight {
        return PanModalHeightMake(.content, 394)
    }
    
    override func showDragIndicator() -> Bool {
        return false
    }
        
    override func panScrollable() -> UIScrollView? {
        nil
    }
    
//    override func isAutoHandleKeyboardEnabled() -> Bool {
//        return false
//    }
    
    override func keyboardOffsetFromInputView() -> CGFloat {
        30
    }
    
    override func allowsTapBackgroundToDismiss() -> Bool {
        false
    }
    
}
