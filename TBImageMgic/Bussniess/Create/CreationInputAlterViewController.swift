//
//  CreationInputAlterViewController.swift
//  TBImageMgic
//
//  Created by wplive on 2024/7/21.
//

import UIKit
import Foundation
import HWPanModal

// 输入prompt内容
class CreationInputAlterViewController : UIViewController {
    
    let textView = UITextView()
    let placeHolderLabel = UILabel()
    
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
        textView.becomeFirstResponder()
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            let keyboardHeight = keyboardFrame.height
//            let bottomSpace = view.frame.height - (textField.frame.origin.y + textField.frame.height)
//            let difference = keyboardHeight - bottomSpace + 20 // 加一点额外的空间
            
//            if difference > 0 {
//                view.frame.origin.y = -difference
//            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
//        view.frame.origin.y = 0
    }
}

extension CreationInputAlterViewController {
    func setupNav() {
        let line = UIView(frame: CGRect(x: (UIScreen.width - 36)*0.5, y: 6, width: 36, height: 5))
        line.backgroundColor = UIColor(hexString: "#7f7f7f")?.withAlphaComponent(0.4)
        line.layer.masksToBounds = true
        line.layer.cornerRadius = 2.5
        view.addSubview(line)
        
        let title = UILabel(frame: CGRect(x: (UIScreen.width - 100) * 0.5, y: 16, width: 100, height: 24))
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 17, weight: .bold)
        title.text = localizedStr("Prompt")
        title.textColor = UIColor.white
        view.addSubview(title)
        
        let btnWidth : CGFloat = 73
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.frame = CGRect(x: 6, y: 6, width: btnWidth, height: 44)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 17)
        cancelBtn.setTitle(localizedStr("Cancel"), for: .normal)
        cancelBtn.setTitleColor(UIColor(hexString: "#6576F9"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(clickCancelAction), for: .touchUpInside)
        view.addSubview(cancelBtn)
        
        let saveBtn = UIButton(type: .custom)
        saveBtn.frame = CGRect(x: (UIScreen.width - 6 - btnWidth), y: 6, width: btnWidth, height: 44)
        saveBtn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        saveBtn.setTitle(localizedStr("Save"), for: .normal)
        saveBtn.setTitleColor(UIColor(hexString: "#6576F9"), for: .normal)
        saveBtn.addTarget(self, action: #selector(clickSaveAction), for: .touchUpInside)
        view.addSubview(saveBtn)
    }
    
    func setupViews() {
        view.backgroundColor = UIColor(hexString: "#19191A")
        
        let leftMargin : CGFloat = 20
        let rightMargin : CGFloat = 20
        let contentWidth : CGFloat = UIScreen.width - leftMargin - rightMargin
        
        let inputBgView = UIView(frame: CGRect(x: leftMargin, y: 58, width: contentWidth, height: 167))
        inputBgView.backgroundColor = UIColor(hexString: "#1F1F1F")
        inputBgView.layer.cornerRadius = 10
        inputBgView.layer.masksToBounds = true
        view.addSubview(inputBgView)
        
        placeHolderLabel.frame = CGRect(x: 12, y: 12, width: contentWidth - 24, height: 48)
        placeHolderLabel.textColor = .white.withAlphaComponent(0.64)
        placeHolderLabel.font = .systemFont(ofSize: 16)
        placeHolderLabel.numberOfLines = 0
        let text = localizedStr("描述你想象中这张照片发生的动作")
        placeHolderLabel.text = text
        
        let labelHeight = Utils.textHeight(text: text, font: placeHolderLabel.font, width: placeHolderLabel.width)
        placeHolderLabel.height = labelHeight
        
        inputBgView.addSubview(placeHolderLabel)
        
        textView.frame = CGRect(x: 5, y: 5, width: contentWidth - 10, height: inputBgView.height - 10)
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.font = .systemFont(ofSize: 16)
        inputBgView.addSubview(textView)
        
        textView.text = inputText
        textViewDidChange(textView)
    }
}

// actions
extension CreationInputAlterViewController {
    @objc func clickCancelAction() {
        dismiss(animated: true)
    }
    
    @objc func clickSaveAction() {
        submitPromptBlock?(textView.text)
        dismiss(animated: false)
    }
    
    
    
}

extension CreationInputAlterViewController  : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLabel.isHidden = textView.text.count > 0
    }
    
    
}


extension CreationInputAlterViewController {
    private func addObservers() {

    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func textViewDidChange() {
        
    }
    
}


extension CreationInputAlterViewController {
    
    override func longFormHeight() -> PanModalHeight {
        return PanModalHeightMake(.topInset, 44)
    }
    
    override func showDragIndicator() -> Bool {
        return false
    }
        
    override func panScrollable() -> UIScrollView? {
        nil
    }
    
    override func isAutoHandleKeyboardEnabled() -> Bool {
        return false
    }
    
    
    
}
