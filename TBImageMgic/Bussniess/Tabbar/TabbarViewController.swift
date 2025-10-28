
import Foundation
import UIKit

enum TabbarIndexType: Int {
    case home = 0
    case create = 1
    case lib = 2
}

protocol TabbarSubViewControllerProtocol {
    func doubleClickTabbarItem()
}


class TabbarViewController: UITabBarController {
    private let tabbarView = TabbarView()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        delegate = self
        
        setUpMainUI()
        addObservers()
        
        tabbarView.selected(index: .home)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabbarView.frame = CGRect(x: 0, y: UIScreen.height - UIScreen.tabbarHeight, width: UIScreen.width, height: UIScreen.tabbarHeight)
    }
    
    static func tabbarVC() -> TabbarViewController? {
        if let de = UIApplication.shared.delegate as? AppDelegate {
            return de.tabbarVC
        }
        return nil
    }
    
    func changeTab(index: TabbarIndexType) {
        tabbarViewDidSelect(index: index)
    }
    
    func clickCreateAction() {
        enterCreationVc(imgCount: 1)
    }
    
    func enterCreationVc( imgCount : Int ) {
        let vc = CreationViewControllerV2()
//        vc.imageCount = imgCount
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func enterTextCreateVc() {
        let vc = TextCreationViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
    
}

// MARK: UI
extension TabbarViewController {

    private func buildSubVC() {
        let homeVc = HomeViewController()
        let createVc = UIViewController()
        let libVc = LibraryViewController()
        
        viewControllers = [homeVc, createVc, libVc]
    }
    
    private func setUpMainUI() {
        tabbarView.delegate = self
        view.addSubview(tabbarView)
        buildSubVC()
    }
}

// MARK: Observers
extension TabbarViewController {
    
    private func addObservers() {
        
        // auth 完成
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateToken), name: .Account.didUpdateToken, object: nil)
    }
    
    @objc private func didUpdateToken() {
      
    }
}

extension TabbarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let lastIndex = tabBarController.selectedIndex
        var currentIndex = -1
        var currentVc : UIViewController? = nil
        tabBarController.viewControllers?.enumerated().forEach({ element in
            if element.element == viewController {
                currentIndex = element.offset
                currentVc = viewController
            }
        })
        
        if lastIndex == currentIndex, let vc = currentVc as? TabbarSubViewControllerProtocol {
            vc.doubleClickTabbarItem()
        }

        NotificationCenter.default.post(name: .Tabbar.itemSelect, object: nil, userInfo: ["lastIndex": lastIndex, "currentIndex": currentIndex])
        return true
    }
}

extension TabbarViewController: TabbarViewDelegate {
    func tabbarViewDidSelect(index: TabbarIndexType) {
        if index == .create {
            clickCreateAction()
        }
        else {
            handlerSelect(index: index)
        }
    }
    
    private func handlerSelect(index: TabbarIndexType) {
        let dex = index.rawValue
        guard let vcs = viewControllers, vcs.count > dex else {
            return
        }
        tabbarView.selected(index: index)
        let _ = tabBarController(self, shouldSelect: vcs[dex])
        selectedIndex = dex
        
        reportExpose()
    }
}

// MARK: Report
extension TabbarViewController {
    private func reportExpose() {
       
    }
}

