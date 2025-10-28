//
//  LumaTemplateSectionView.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import UIKit

protocol LumaTemplateSectionViewDelegate: AnyObject {
    func templateSectionDidSelectAll(_ template: LumaTemplateModel)
    func templateSectionDidSelectTemplate(_ template: LumaTemplateModel)
}

class LumaTemplateSectionView: UIView {

    weak var delegate: LumaTemplateSectionViewDelegate?
    private let template: LumaTemplateModel
    private let templates: [LumaTemplateModel]

    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let seeAllButton = UIButton(type: .system)
    private let collectionView: UICollectionView

    init(template: LumaTemplateModel, subTemplates: [LumaTemplateModel]) {
        self.template = template
        self.templates = subTemplates
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear

        // 设置标题
        titleLabel.text = template.localizedName
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white

        // 设置查看全部按钮
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.setTitleColor(.systemPink, for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)

        // 设置CollectionView
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(LumaTemplateSectionCell.self, forCellWithReuseIdentifier: "TemplateSectionCell")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        // 添加到视图
        addSubview(headerView)
        addSubview(collectionView)

        headerView.addSubview(titleLabel)
        headerView.addSubview(seeAllButton)

        setupConstraints()
    }

    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            seeAllButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            seeAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func seeAllTapped() {
        delegate?.templateSectionDidSelectAll(template)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension LumaTemplateSectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(templates.count, 8) // 最多显示8个
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TemplateSectionCell", for: indexPath) as! LumaTemplateSectionCell
        let template = templates[indexPath.item]
        cell.configure(with: template)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.bounds.width - 48) / 3 // 3列，间距12
        let height: CGFloat = width * 1.5 // 3:2宽高比
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let template = templates[indexPath.item]
        delegate?.templateSectionDidSelectTemplate(template)
    }
}

// MARK: - Template Section Cell

class LumaTemplateSectionCell: UICollectionViewCell {

    private let imageView = UIImageView()
    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()

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
        // 设置卡片样式
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        // 设置图片
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        // 设置渐变层
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        imageView.layer.addSublayer(gradientLayer)

        // 设置标题
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

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

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 6)
        ])
    }
}