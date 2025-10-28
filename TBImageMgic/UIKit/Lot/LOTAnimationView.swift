//
//  LOTView.swift
//  lottie-oc
//
//  Created by 刘立超 on 2020/2/3.
//  Copyright © 2020 刘立超. All rights reserved.
//
import Foundation
import UIKit
import AVFoundation
import Lottie
import YYCache

fileprivate func CompatibleAnimationGetAnimation(compatibleAnimation: LOTAnimation, for traitCollection: UITraitCollection) -> LottieAnimation? {
    if #available(iOS 13.0, *) {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return compatibleAnimation.darkModeAnimation
        case .light, .unspecified:
            fallthrough
        default:
            return compatibleAnimation.animation
        }
    } else {
        return compatibleAnimation.animation
    }
}

fileprivate func CompatibleAnimationGetImageProvider(compatibleAnimation: LOTAnimation, for traitCollection: UITraitCollection) -> LOTCustomImageProvider {
    if #available(iOS 13.0, *) {
        let filePath: String
        switch traitCollection.userInterfaceStyle {
        case .dark:
            filePath = compatibleAnimation.darkModeFilePath ?? compatibleAnimation.filepath
        case .light, .unspecified:
            fallthrough
        default:
            filePath = compatibleAnimation.filepath
        }
        return LOTCustomImageProvider(folderPath: (filePath as NSString).deletingLastPathComponent)
    } else {
        return LOTCustomImageProvider(folderPath: (compatibleAnimation.filepath as NSString).deletingLastPathComponent)
    }
}

fileprivate extension LottieAnimationView {
    func associateAnimationWithCompatibleAnimation(_ compatibleAnimation: LOTAnimation) {
        animation = CompatibleAnimationGetAnimation(compatibleAnimation: compatibleAnimation, for: traitCollection)
    }
    
    func associateImageProviderWithCompatibleAnimation(_ compatibleAnimation: LOTAnimation) {
        imageProvider = CompatibleAnimationGetImageProvider(compatibleAnimation: compatibleAnimation, for: traitCollection)
    }
}

/// An Objective-C compatible wrapper around Lottie's Animation class.
/// Use in tandem with CompatibleAnimationView when using Lottie in Objective-C
private
final class LOTAnimation: NSObject {
    
    let filepath: String
    let darkModeFilePath: String?
    
    var useCache: Bool = true
    fileprivate var animation: LottieAnimation? {
        if useCache {
            return LottieAnimation.filepath(filepath, animationCache: LRUAnimationCache.sharedCache)
        } else {
            return LottieAnimation.filepath(filepath)
        }
    }
    
    fileprivate var darkModeAnimation: LottieAnimation? {
        guard let darkModeFilePath = darkModeFilePath else {
            return animation
        }

        if useCache {
            return LottieAnimation.filepath(darkModeFilePath, animationCache: LRUAnimationCache.sharedCache)
        } else {
            return LottieAnimation.filepath(darkModeFilePath)
        }
    }

    @objc init(dbundle: Bundle?, bundle: String, forder: String, darkModeBundle: String?, darkModeForder: String?) {
//        var path: String?
        if let dbundle = dbundle, let bundlePath = dbundle.path(forResource: bundle, ofType: "bundle")  {
            self.filepath = bundlePath + "/" + forder + "/data.json"
        } else {
            if let bundlePath = Bundle.main.path(forResource: bundle, ofType: "bundle") {
                self.filepath = bundlePath + "/" + forder + "/data.json"
            } else {
                self.filepath = forder + "/data.json"
            }
        }
        
        if
            let darkModeBundle = darkModeBundle,
            let darkModeForder = darkModeForder
        {
            if let darkModeBundlePath = Bundle.main.path(forResource: darkModeBundle, ofType: "bundle") {
                self.darkModeFilePath = darkModeBundlePath + "/" + darkModeForder + "/data.json"
            } else {
                self.darkModeFilePath = darkModeForder + "/data.json"
            }
        } else {
            self.darkModeFilePath = nil
        }
    }
    @objc init(bundle: String, forder: String, darkModeBundle: String?, darkModeForder: String?) {
        if let bundlePath = Bundle.main.path(forResource: bundle, ofType: "bundle") {
            self.filepath = bundlePath + "/" + forder + "/data.json"
        } else {
            self.filepath = forder + "/data.json"
        }
        
        if
            let darkModeBundle = darkModeBundle,
            let darkModeForder = darkModeForder
        {
            if let darkModeBundlePath = Bundle.main.path(forResource: darkModeBundle, ofType: "bundle") {
                self.darkModeFilePath = darkModeBundlePath + "/" + darkModeForder + "/data.json"
            } else {
                self.darkModeFilePath = darkModeForder + "/data.json"
            }
        } else {
            self.darkModeFilePath = nil
        }
    }
    
    @objc init(filepath: String, darkModeFilePath: String?) {
        self.filepath = filepath
        self.darkModeFilePath = darkModeFilePath
        super.init()
    }
}

/// An Objective-C compatible wrapper around Lottie's AnimationView.
@objc public
final class LOTAnimationView: UIView {
    @objc public static func animationWithFilePath(
        _ path: String,
        darkModeFilePath: String?
    ) -> LOTAnimationView {
        return LOTAnimationView(
            compatibleAnimation: LOTAnimation(
                filepath: path,
                darkModeFilePath: darkModeFilePath))
    }
    
    @objc public
    convenience init(bundle: String, forder: String, darkModeBundle: String?, darkModeForder: String?) {
        let lot = LOTAnimation(
            bundle: bundle, forder: forder,
            darkModeBundle: darkModeBundle, darkModeForder: darkModeForder)
        self.init(compatibleAnimation: lot)
    }
    
    @objc public
    convenience init(dbundle: Bundle, bundle: String, forder: String, darkModeBundle: String?, darkModeForder: String?) {
        let lot = LOTAnimation(dbundle:dbundle,
            bundle: bundle, forder: forder,
            darkModeBundle: darkModeBundle, darkModeForder: darkModeForder)
        self.init(compatibleAnimation: lot)
    }
    
    fileprivate init(compatibleAnimation: LOTAnimation) {
        animationView = LottieAnimationView(
            animation: nil,
            imageProvider: nil,
            textProvider: DefaultTextProvider(),
            fontProvider: DefaultFontProvider())
        animationView.associateAnimationWithCompatibleAnimation(compatibleAnimation)
        animationView.associateImageProviderWithCompatibleAnimation(compatibleAnimation)
        self.compatibleAnimation = compatibleAnimation
        super.init(frame: .zero)
        commonInit()
    }

    @objc public
    override init(frame: CGRect) {
        animationView = LottieAnimationView()
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 13.0, *) {
            if animationView.isAnimationPlaying || animationView.isAnimationQueued {
                setNeedsSwitchAnimation()
                return
            }
            if
                let window = window,
                let compatibleAnimation = compatibleAnimation
            {
                animationView.animation = CompatibleAnimationGetAnimation(
                    compatibleAnimation: compatibleAnimation,
                    for: window.traitCollection)
                animationView.imageProvider = CompatibleAnimationGetImageProvider(
                    compatibleAnimation: compatibleAnimation,
                    for: window.traitCollection)
            }
        }
    }
    
    private func switchAnimation() {
        assert(Thread.isMainThread)
        
        if let compatibleAnimation = compatibleAnimation {
            animationView.animation = CompatibleAnimationGetAnimation(
                compatibleAnimation: compatibleAnimation,
                for: traitCollection)
            animationView.imageProvider = CompatibleAnimationGetImageProvider(
                compatibleAnimation: compatibleAnimation,
                for: traitCollection)
        }
        
        needsSwitchAnimation = false
    }
    
    private var needsSwitchAnimation = false
    private func setNeedsSwitchAnimation() {
        assert(Thread.isMainThread)
        needsSwitchAnimation = true
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if animationView.isAnimationPlaying || animationView.isAnimationQueued {
                setNeedsSwitchAnimation()
            } else {
                switchAnimation()
            }
        }
    }

  // MARK: Public
    @objc public
    var useCache: Bool = true
    
    public
    var folderPath: (bundle: String, name: String, darkModeBundle: String?, darkModeForder: String?)? {
        didSet {
            guard let path = folderPath else { return }
            self.compatibleAnimation = LOTAnimation(
                bundle: path.bundle, forder: path.name,
                darkModeBundle: path.darkModeBundle, darkModeForder: path.darkModeForder)
        }
    }
    
    @objc(LOTAnimationViewFilePath) public
    class LOTAnimationViewFilePath: NSObject {
        @objc public let lightMode: String
        @objc public let darkMode: String?
        
        @objc public init(lightMode: String, darkMode: String?) {
            self.lightMode = lightMode
            self.darkMode = darkMode
        }
    }
    
    @objc public
    var ocFilePath: LOTAnimationViewFilePath? {
        didSet {
            if let ocFilePath = ocFilePath {
                self.filePath = (ocFilePath.lightMode, ocFilePath.darkMode)
            } else {
                self.filePath = nil
            }
        }
    }
    
    var filePath: (light: String, dark: String?)? {
        didSet {
            guard let path = filePath else { return }
            self.compatibleAnimation = LOTAnimation(
                filepath: path.light,
                darkModeFilePath: path.dark)
        }
    }
    
    @objc public
    override var frame: CGRect {
        didSet {
            animationView.frame = self.bounds
        }
    }

    private var compatibleAnimation: LOTAnimation? {
        didSet {
            if
                let compatibleAnimation = compatibleAnimation
            {
                animationView.associateAnimationWithCompatibleAnimation(compatibleAnimation)
                animationView.associateImageProviderWithCompatibleAnimation(compatibleAnimation)
            } else {
                animationView.animation = nil
            }
            compatibleAnimation?.useCache = self.useCache
        }
    }

    /// Returns `true` if the animation is currently playing.
    @objc public
    var isAnimationPlaying: Bool {
        return animationView.isAnimationPlaying
    }
    
    @objc public
    var loopAnimationCount: CGFloat = 0 {
        didSet {
            animationView.loopMode = loopAnimationCount == -1 ? .loop : .repeat(Float(loopAnimationCount))
        }
    }

    @objc public
    override var contentMode: UIView.ContentMode {
        set { animationView.contentMode = newValue }
        get { return animationView.contentMode }
    }

    @objc public
    var shouldRasterizeWhenIdle: Bool {
        set { animationView.shouldRasterizeWhenIdle = newValue }
        get { return animationView.shouldRasterizeWhenIdle }
    }

    @objc public
    var currentProgress: CGFloat {
        set { animationView.currentProgress = newValue }
        get { return animationView.currentProgress }
    }

    @objc public
    var currentTime: TimeInterval {
        set { animationView.currentTime = newValue }
        get { return animationView.currentTime }
    }

    @objc public
    var currentFrame: CGFloat {
        set { animationView.currentFrame = newValue }
        get { return animationView.currentFrame }
    }

    @objc public
    var realtimeAnimationFrame: CGFloat {
        return animationView.realtimeAnimationFrame
    }

    @objc public
    var realtimeAnimationProgress: CGFloat {
        return animationView.realtimeAnimationProgress
    }

    @objc public
    var animationSpeed: CGFloat {
        set { animationView.animationSpeed = newValue }
        get { return animationView.animationSpeed }
    }

    @objc public
    var respectAnimationFrameRate: Bool {
        set { animationView.respectAnimationFrameRate = newValue }
        get { return animationView.respectAnimationFrameRate }
    }
    
    private func blockAfterPlayCompleted(_ block: ((Bool) -> ())?) -> (Bool) -> () {
        return { [weak self] completed in
            block?(completed)
            if
                let sself = self,
                sself.needsSwitchAnimation
            {
                sself.switchAnimation()
            }
        }
    }
    
    @objc public
    func play() {
        play(completion: nil)
    }

    @objc public
    func play(completion: ((Bool) -> Void)?) {
        reseted = false
        animationView.play(completion: blockAfterPlayCompleted(completion))
    }
    
    @objc public
    func play(toProgress: CGFloat, withCompletion: ((Bool) -> Void)? = nil) {
        reseted = false
        animationView.play(
            toProgress: toProgress,
            completion: blockAfterPlayCompleted(withCompletion))
    }

    @objc public
    func play(fromProgress: CGFloat, toProgress: CGFloat, withCompletion: ((Bool) -> Void)? = nil) {
        reseted = false
        animationView.play(
            fromProgress: fromProgress,
            toProgress: toProgress,
            loopMode: nil,
            completion: blockAfterPlayCompleted(withCompletion))
    }

    @objc public
    func play(fromFrame: CGFloat, toFrame: CGFloat, completion: ((Bool) -> Void)? = nil) {
        reseted = false
        animationView.play(
            fromFrame: fromFrame,
            toFrame: toFrame,
            loopMode: nil,
            completion: blockAfterPlayCompleted(completion))
    }

    @objc public
    func play(fromMarker: String, toMarker: String, completion: ((Bool) -> Void)? = nil) {
        reseted = false
        animationView.play(
            fromMarker: fromMarker,
            toMarker: toMarker,
            completion: blockAfterPlayCompleted(completion))
    }

    @objc public
    func stop() {
        animationView.stop()
    }
    
    @objc public
    func clear() {
        animationView.animation = nil
    }
    
    private var reseted = true
    @objc public
    func reset() {
        guard !reseted else {
            if currentProgress != 0 {
                animationView.currentProgress = 0
            }
            return
        }
        if let compatibleAnimation = compatibleAnimation {
            filePath = (compatibleAnimation.filepath, compatibleAnimation.darkModeFilePath)
        } else {
            filePath = nil
        }
        reseted = true
    }

    @objc public
    func pause() {
        animationView.pause()
    }

    @objc public
    func reloadImages() {
        animationView.reloadImages()
    }

    @objc public
    func forceDisplayUpdate() {
        animationView.forceDisplayUpdate()
    }

    @objc public
    func getValue(for keypath: CompatibleAnimationKeypath, atFrame: CGFloat) -> Any? {
        return animationView.getValue(for: keypath.animationKeypath, atFrame: atFrame)
    }

    @objc public
    func logHierarchyKeypaths() {
        animationView.logHierarchyKeypaths()
    }

    @objc public
    func addSubview(_ subview: AnimationSubview, forLayerAt keypath: CompatibleAnimationKeypath) {
        animationView.addSubview(subview, forLayerAt: keypath.animationKeypath)
    }

    @objc public
    func convert(rect: CGRect, toLayerAt keypath: CompatibleAnimationKeypath?) -> CGRect {
        return animationView.convert(rect, toLayerAt: keypath?.animationKeypath) ?? .zero
    }

    @objc public
    func convert(point: CGPoint, toLayerAt keypath: CompatibleAnimationKeypath?) -> CGPoint {
        return animationView.convert(point, toLayerAt: keypath?.animationKeypath) ?? .zero
    }

    @objc public
    func progressTime(forMarker named: String) -> CGFloat {
        return animationView.progressTime(forMarker: named) ?? 0
    }

    @objc public
    func frameTime(forMarker named: String) -> CGFloat {
        return animationView.frameTime(forMarker: named) ?? 0
    }

    // MARK: Private

    private let animationView: LottieAnimationView

    private func commonInit() {
        animationView.backgroundBehavior = .pauseAndRestore
        setUpViews()
    }

    private func setUpViews() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(animationView)
        animationView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        animationView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        animationView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        animationView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

private var kppLottieUrl = "pp.lottie.url"
private let lottieYYCache: YYDiskCache = {
    let lottieYYCachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/pp.lottie.cache"
    let cache = YYDiskCache(path: lottieYYCachePath)!
    cache.countLimit = 1024*1024*5
    return cache
} ()

extension LottieAnimationView {
    
    public
    func setUrl(_ url: String?, callback:((Error?) -> Void)? = nil) {
        _setUrl(url, callback: callback)
        lottieYYCache.countLimit = 1024 * 1024 * 10
    }
    
    private(set) var lottieUrl: String? {
        get {
            return objc_getAssociatedObject(self, &kppLottieUrl) as? String
        }
        set {
            objc_setAssociatedObject(self, &kppLottieUrl, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private func _setUrl(_ url: String?, callback:((Error?) -> Void)? = nil) {
        lottieUrl = url
        
        guard let urlStr = url, let urlValue = URL(string: urlStr) else {
            callback?(NSError(domain: "com.pp.custom", code: -1, userInfo: [NSLocalizedDescriptionKey : "url错误"]))
            return
        }
        let key = urlStr.md5
        
        if let animation = LRUAnimationCache.sharedCache.animation(forKey: key) {
            self.animation = animation
            callback?(nil)
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if let data = lottieYYCache.object(forKey: key) as? Data, let animation = try? JSONDecoder().decode(LottieAnimation.self, from: data) {
                guard let sself = self, sself.lottieUrl == url else { return }
                DispatchQueue.main.async {
                    self?.animation = animation
                    callback?(nil)
                }
            } else {
                let task = URLSession.shared.dataTask(with: urlValue) { [weak self] (data, response, error) in
                    guard let sself = self, sself.lottieUrl == url else { return }
                    if let data = data, let animation = try? JSONDecoder().decode(LottieAnimation.self, from: data)  {
                        LRUAnimationCache.sharedCache.setAnimation(animation, forKey: key)
                        lottieYYCache.setObject(data as NSCoding, forKey: key)
                        if sself.lottieUrl == url {
                            DispatchQueue.main.async {
                                self?.animation = animation
                                callback?(nil)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            callback?(error)
                        }
                    }
                }
                task.resume()
            }
        }
    }
}
