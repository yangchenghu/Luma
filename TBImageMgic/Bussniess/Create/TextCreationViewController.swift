
import UIKit
import Foundation

class PromptInfoViewModel : NSObject {
    var prompt : PromptInfo?
    
    var cellSize : CGSize = CGSizeZero
    
    override init() {
        super.init()
        
    }
    
    func bind(p : PromptInfo) {
        prompt = p
        let textWidth : CGFloat = Utils.textWidth(text: p.title, font: .systemFont(ofSize: 15), height: 19)
        cellSize = CGSize(width: 8 + textWidth + 8, height: 34)
    }
}



class TextCreationViewController : CreationBaseViewController {
    
    let textView : UITextView = UITextView()
    let placeHolderLabel : UILabel = UILabel()
    
    var collectionView : UICollectionView?
    var list : [PromptInfoViewModel] = []
    
    deinit {
        removeObservers()
    }
    
    
    override init() {
        super.init()
        
        self.showBgImage = true
        self.showNavTitle = true
        self.showHeaderView = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNav()
        setupViews()
        buildData()
        addObservers()
    }
    
    
    @objc override func clickCreateAction() {
        if textView.text.count == 0 {
            Toast.showToast(localizedStr("请输入内容"))
            return
        }
        
        let api = AIApi.createTextCreation(text: textView.text, can_share: false, user_name: "", cnt: 1)
        api.post {[weak self] data, msg in
            guard let data else { return }
            
            let list = data.arrayDictionaryValueForKey("creation_list")
            let creationList = list.map { CreationInfo(info: $0) }
            
            if let creation = creationList.first, creation.creationId != 0 {
                self?.enterDetail(creation: creation)
                LibraryViewDataSource.shared.loadData()
            }
            else {
                let error : String = localizedStr("creation error") + "!!!"
                Toast.showToast(error)
            }
        } failBlock: { [weak self] error in
            let msg = error?.localizedDescription ?? ""
            debugPrint(msg)
            HUD.hiddenHud()
            Toast.showToast(msg)
            
            if let ret = error?.code, ret == -101 {
                // 余额不足，拉充值
                self?.charge()
            }
        }
    }

    
}

// UI
extension TextCreationViewController {
    
    func setupNav() {
        navHeaderView.backgroundColor = .clear
        navTitleLabel.text = localizedStr("文字生成视频")
        
    }
    
    func setupViews() {
        let left : CGFloat = 20
        let right : CGFloat = 20
        var top : CGFloat = UIScreen.topHeight + 10
        let contentWidth : CGFloat = UIScreen.width - left - right
        
        let btnSpace : CGFloat = 12
        let btnHeight : CGFloat = 96
        
        let btnsView = UIView(frame: CGRect(x: left, y: top, width: contentWidth, height: btnHeight))
        let btnWidth : CGFloat = (contentWidth - btnSpace) * 0.5
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: btnWidth, height: btnHeight))
        leftView.backgroundColor = UIColor(hexString: "#787880")?.withAlphaComponent(0.2)
        leftView.layer.cornerRadius = 12
        leftView.layer.masksToBounds = true
        leftView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let leftImg : UIImageView = UIImageView(frame: CGRect(x: (btnWidth - 28) * 0.5, y: 15, width: 28, height: 28))
        leftImg.image = UIImage(named: "icons_text_to_video")
        leftView.addSubview(leftImg)
        
        let leftLabel : UILabel = UILabel(frame: CGRect(x: 0, y: 50, width: btnWidth, height: 18))
        leftLabel.textAlignment = .center
        leftLabel.textColor = UIColor(hexString: "#838BF7")
        leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        leftLabel.text = localizedStr("文字生成视频")
        leftView.addSubview(leftLabel)
        
        btnsView.addSubview(leftView)
        
        let rightView = UIView(frame: CGRect(x: btnWidth + btnSpace, y: 0, width: btnWidth, height: 84))
        rightView.backgroundColor = UIColor(hexString: "#6F72F6")
        rightView.layer.cornerRadius = 12
        rightView.layer.masksToBounds = true
        btnsView.addSubview(rightView)
        
        let rightImg : UIImageView = UIImageView(frame: CGRect(x: (btnWidth - 28) * 0.5, y: 15, width: 28, height: 28))
        rightImg.image = UIImage(named: "icons_image_to_video")
        rightView.addSubview(rightImg)
        
        let rightLabel : UILabel = UILabel(frame: CGRect(x: 0, y: 50, width: btnWidth, height: 18))
        rightLabel.textAlignment = .center
        rightLabel.textColor = .white
        rightLabel.font = .systemFont(ofSize: 16, weight: .medium)
        rightLabel.text = localizedStr("图片生成视频")
        rightView.addSubview(rightLabel)
        
        rightView.tapBlock = { [weak self] in
            self?.clickImageToVideo()
        }
        
        view.addSubview(btnsView)
        
        top += btnsView.height
        
        let inputView = UIView(frame: CGRect(x: left, y: top, width: contentWidth, height: 240))
        inputView.backgroundColor = UIColor(hexString: "#787880")?.withAlphaComponent(0.2)
        inputView.layer.cornerRadius = 12
        inputView.layer.masksToBounds = true
        inputView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        textView.frame = CGRect(x: 5, y: 5, width: contentWidth - 10, height: 240 - 10)
        textView.backgroundColor = .clear
        textView.returnKeyType = .done
        textView.font = .systemFont(ofSize: 16)
        textView.delegate = self
        
        placeHolderLabel.font = .systemFont(ofSize: 16)
        placeHolderLabel.text = localizedStr("输入一些提示")
        placeHolderLabel.textColor = UIColor(hexString: "#494949")
        placeHolderLabel.frame = CGRect(x: 10, y: 12, width: contentWidth - 20, height: 22)
        inputView.addSubview(placeHolderLabel)
        inputView.addSubview(textView)
        
        view.addSubview(inputView)
        top += inputView.height
        top += 16
        
        let createBtnHeight : CGFloat = 56
        let createBtnTop = UIScreen.height - UIScreen.bottomSafeHeight - 10 - createBtnHeight
        
        let createBtn = UIButton(type: .custom)
        createBtn.frame = CGRect(x: left, y: createBtnTop, width: contentWidth, height: createBtnHeight)
        createBtn.backgroundColor = UIColor(hexString: "#6F72F6")
        createBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        createBtn.setTitleColor(.white, for: .normal)
        createBtn.layer.cornerRadius = createBtnHeight * 0.5
        createBtn.layer.masksToBounds = true
        let title : String = localizedStr("Create") + "(\(AccountManager.userInfo.txt2VideoCoins)" + "💎)"
        createBtn.setTitle(title, for: .normal)
        createBtn.addTarget(self, action: #selector(clickCreateAction), for: .touchUpInside)
        view.addSubview(createBtn)

        
        let cHeight : CGFloat = createBtnTop - top
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        
        let collecton = UICollectionView(frame: CGRect(x: left, y: top, width: contentWidth , height: cHeight), collectionViewLayout: layout)
        collecton.delegate = self
        collecton.dataSource = self
        collecton.showsHorizontalScrollIndicator = false
        collecton.showsVerticalScrollIndicator = false
        collecton.backgroundColor = .clear
        collecton.register(TextTagCollectionCell.self, forCellWithReuseIdentifier: NSStringFromClass(TextTagCollectionCell.self))
//        collecton.backgroundColor = .red
        view.addSubview(collecton)
        collectionView = collecton
        
        let tap = UITapGestureRecognizer { [weak self] gesture in
            self?.textView.resignFirstResponder()
        }
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
}
// Action
extension TextCreationViewController {
    
    func buildData() {
        list.removeAll()
        let l : [PromptInfoViewModel] = ConfigManager.shared.promptList.map{
            let p = PromptInfoViewModel()
            p.bind(p: $0)
            return p
        }
        list = list + l
        collectionView?.reloadData()
    }
    
    func clickImageToVideo() {
        let vc = CreationViewControllerV2()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension TextCreationViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLabel.isHidden = textView.text.count > 0
    }
    
    
}


extension TextCreationViewController {
    
    private func addObservers() {
//        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChanged), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    private func removeObservers() {
//        NotificationCenter.default.removeObserver(self)
    }
    
//    @objc func textViewDidChanged() {
//        placeHolderLabel.isHidden = textView.text.count > 0
//    }
    
}

extension TextCreationViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let vm = list[indexPath.row]
        return vm.cellSize
    }
}

extension TextCreationViewController : UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < list.count {
            let vm = list[indexPath.row]
            textView.text = vm.prompt?.detail
            textViewDidChange(textView)
        }
    }
}

extension TextCreationViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TextTagCollectionCell.self), for: indexPath) as! TextTagCollectionCell
        if indexPath.row < list.count {
            let vm = list[indexPath.row]
            cell.bind(vm: vm)
        }
        return cell
    }
    
}


class TextTagCollectionCell : UICollectionViewCell {
    
    let textLabel : UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel.frame = bounds
        textLabel.textAlignment = .center
        textLabel.textColor = .white
        textLabel.backgroundColor = UIColor(hexString: "#787880")?.withAlphaComponent(0.2)
        textLabel.layer.cornerRadius = 8
        textLabel.layer.masksToBounds = true
        contentView.addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(vm : PromptInfoViewModel) {
        textLabel.text = vm.prompt?.title
    }
}

