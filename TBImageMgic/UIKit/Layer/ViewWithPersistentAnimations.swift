
import UIKit
import Foundation

class ViewWithPersistentAnimations : UIView {
    /// view 是否可见
    var isAppear : Bool = true
    /// 是否已经保存动画
    var isSaved : Bool = false
    private var persistentAnimations: [String: CAAnimation] = [:]
    private var persistentSpeed: Float = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func didBecomeActive() {
        guard isAppear else { return }
        recoverAnimations()
    }

    @objc func willResignActive() {
        guard isAppear else { return }
        saveAnimations()
    }
    
    // 恢复动画效果
    private func recoverAnimations() {
        guard isSaved else { return }
        
        self.restoreAnimations(withKeys: Array(self.persistentAnimations.keys))
        self.persistentAnimations.removeAll()
        if self.persistentSpeed == 1.0 { //if layer was plaiyng before backgorund, resume it
            self.layer.resume()
        }
        
        isSaved = false
    }
    
    // 缓存动画效果
    private func saveAnimations() {
        guard !isSaved else { return }
        
        self.persistentSpeed = self.layer.speed

        self.layer.speed = 1.0 //in case layer was paused from outside, set speed to 1.0 to get all animations
        self.persistAnimations(withKeys: self.layer.animationKeys())
        self.layer.speed = self.persistentSpeed //restore original speed
        self.layer.pause()
        
        isSaved = true
    }
    
    private func persistAnimations(withKeys: [String]?) {
        withKeys?.forEach({ (key) in
            if let animation = self.layer.animation(forKey: key) {
                self.persistentAnimations[key] = animation
            }
        })
    }

    private func restoreAnimations(withKeys: [String]?) {
        withKeys?.forEach { key in
            if let persistentAnimation = self.persistentAnimations[key] {
                self.layer.add(persistentAnimation, forKey: key)
            }
        }
    }
}
