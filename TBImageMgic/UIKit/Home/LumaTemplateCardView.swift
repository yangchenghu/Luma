//
//  LumaTemplateCardView.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import UIKit
import Kingfisher

protocol LumaTemplateCardViewDelegate: AnyObject {
    func templateCardDidTapTry(_ template: LumaTemplateModel)
}

class LumaTemplateCardView: UIView {

    weak var delegate: LumaTemplateCardViewDelegate?
    private let template: LumaTemplateModel

    private let cardView = UIView()
    private let imageView = UIImageView()
    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()

    init(template: LumaTemplateModel) {
        self.template = template
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = imageView.bounds
    }

    private func setupViews() {
        // 设置卡片样式
        cardView.backgroundColor = .clear
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true

        // 设置图片
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        // 设置渐变层
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.9).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)

        // 设置标题
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.text = template.localizedName

        // 添加手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tapGesture)

        // 布局
        cardView.addSubview(imageView)
        imageView.layer.addSublayer(gradientLayer)
        cardView.addSubview(titleLabel)
        addSubview(cardView)

        // 加载图片
        loadImage()

        // 设置约束
        setupConstraints()
    }

    private func loadImage() {
        guard let imageUrl = template.imageUrl, !imageUrl.isEmpty else { return }

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
        cardView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),

            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -5),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8)
        ])
    }

    @objc private func cardTapped() {
        delegate?.templateCardDidTapTry(template)
    }
}