//
//  LumaBannerView.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import UIKit
import Kingfisher

protocol LumaBannerViewDelegate: AnyObject {
    func bannerViewDidTapTry(_ template: LumaTemplateModel, at index: Int)
}

class LumaBannerView: UIView {

    weak var delegate: LumaBannerViewDelegate?
    private var templates: [LumaTemplateModel] = []
    private let collectionView: UICollectionView
    private let pageControl = UIPageControl()

    private var timer: Timer?
    private var currentPage: Int = 0

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopAutoScroll()
    }

    func updateTemplates(_ templates: [LumaTemplateModel]) {
        self.templates = templates
        collectionView.reloadData()
        pageControl.numberOfPages = templates.count
        pageControl.currentPage = 0
        currentPage = 0
        startAutoScroll()
    }

    private func setupViews() {
        backgroundColor = .black

        // 设置CollectionView
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(LumaBannerCell.self, forCellWithReuseIdentifier: "BannerCell")

        // 设置PageControl
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .white.withAlphaComponent(0.5)
        pageControl.isUserInteractionEnabled = false

        addSubview(collectionView)
        addSubview(pageControl)

        setupConstraints()
    }

    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Auto Scroll

    private func startAutoScroll() {
        guard templates.count > 1 else { return }

        stopAutoScroll()
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(autoScrollToNext), userInfo: nil, repeats: true)
    }

    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func autoScrollToNext() {
        guard !templates.isEmpty else { return }

        let nextPage = (currentPage + 1) % templates.count
        let indexPath = IndexPath(item: nextPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension LumaBannerView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as! LumaBannerCell
        let template = templates[indexPath.item]
        cell.configure(with: template)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let template = templates[indexPath.item]
        delegate?.bannerViewDidTapTry(template, at: indexPath.item)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let page = Int(scrollView.contentOffset.x / pageWidth)
        currentPage = page
        pageControl.currentPage = page
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            startAutoScroll()
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        startAutoScroll()
    }
}

// MARK: - Banner Cell

class LumaBannerCell: UICollectionViewCell {

    private let imageView = UIImageView()
    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()
    private let tryButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = imageView.bounds
    }

    func configure(with template: LumaTemplateModel) {
        titleLabel.text = template.localizedName
        loadImage(template.imageUrl)
    }

    private func setupViews() {
        // 设置图片
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        // 设置渐变层
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.6]
        imageView.layer.addSublayer(gradientLayer)

        // 设置标题
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left

        // 设置Try按钮
        tryButton.setTitle("Try", for: .normal)
        tryButton.setTitleColor(.white, for: .normal)
        tryButton.backgroundColor = .systemPink
        tryButton.layer.cornerRadius = 20
        tryButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
        tryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(tryButton)

        setupConstraints()
    }

    private func loadImage(_ imageUrl: String?) {
        guard let imageUrl = imageUrl, !imageUrl.isEmpty else { return }

        if imageUrl.hasPrefix("http") {
            // 网络图片
            let kfOptions: KingfisherOptionsInfo = [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.25)),
                .cacheOriginalImage
            ]

            imageView.kf.setImage(with: URL(string: imageUrl), options: kfOptions)
        } else {
            // 本地图片
            imageView.image = UIImage(named: imageUrl)
        }
    }

    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tryButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: tryButton.topAnchor, constant: -16),

            tryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60)
        ])
    }
}