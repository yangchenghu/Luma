//
//  LumaHomeViewController.swift
//  TBImageMgic
//
//  Created by Claude on 2024/10/28.
//

import UIKit

class LumaHomeViewController: BaseVC {

    // MARK: - Properties
    private var currentPage: Int = 1
    private var bannerTemplates: [LumaTemplateModel] = []
    private var sectionTemplates: [LumaTemplateModel] = []

    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let proButton = UIButton(type: .system)
    private let bannerView = LumaBannerView()
    private var sectionViews: [LumaTemplateSectionView] = []

    // State
    private var isLoading = false
    private var hasMore = false

    // MARK: - Lifecycle
    override init() {
        super.init()
        setupUI()
        loadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .black
        setupScrollView()
        setupProButton()
        setupBannerView()
    }

    private func setupNavigation() {
        title = "LumaVideo"
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white

        // 设置标题样式
        if let titleLabel = navigationController?.navigationBar.topItem?.titleView as? UILabel {
            titleLabel.textColor = .white
            titleLabel.font = .boldSystemFont(ofSize: 20)
        }
    }

    private func setupScrollView() {
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupProButton() {
        proButton.setTitle("PRO", for: .normal)
        proButton.setTitleColor(.white, for: .normal)
        proButton.backgroundColor = .systemPink
        proButton.layer.cornerRadius = 16
        proButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        proButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        proButton.addTarget(self, action: #selector(proButtonTapped), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: proButton)
    }

    private func setupBannerView() {
        bannerView.delegate = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }

    private func updateSectionViews() {
        // 清除旧的section views
        sectionViews.forEach { $0.removeFromSuperview() }
        sectionViews.removeAll()

        var previousView: UIView = bannerView

        for (index, template) in sectionTemplates.enumerated() {
            let sectionView = LumaTemplateSectionView(template: template, subTemplates: [])
            sectionView.delegate = self
            sectionView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(sectionView)
            sectionViews.append(sectionView)

            NSLayoutConstraint.activate([
                sectionView.topAnchor.constraint(equalTo: previousView.bottomAnchor),
                sectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                sectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                sectionView.heightAnchor.constraint(equalToConstant: 200)
            ])

            previousView = sectionView

            // 如果是第二个section，添加创建横幅
            if index == 1 {
                let createBanner = createCreateBanner()
                contentView.addSubview(createBanner)

                NSLayoutConstraint.activate([
                    createBanner.topAnchor.constraint(equalTo: previousView.bottomAnchor),
                    createBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    createBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    createBanner.heightAnchor.constraint(equalToConstant: 80)
                ])

                previousView = createBanner
            }
        }

        // 更新content view底部约束
        contentView.bottomAnchor.constraint(equalTo: previousView.bottomAnchor).isActive = true
    }

    private func createCreateBanner() -> UIView {
        let bannerView = UIView()
        bannerView.backgroundColor = .systemPink.withAlphaComponent(0.2)
        bannerView.layer.cornerRadius = 12
        bannerView.layer.borderWidth = 1
        bannerView.layer.borderColor = UIColor.systemPink.cgColor

        let label = UILabel()
        label.text = "Create Your Own Video"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center

        let arrowIcon = UIImageView()
        arrowIcon.image = UIImage(systemName: "arrow.right")
        arrowIcon.tintColor = .white
        arrowIcon.contentMode = .scaleAspectFit

        bannerView.addSubview(label)
        bannerView.addSubview(arrowIcon)

        label.translatesAutoresizingMaskIntoConstraints = false
        arrowIcon.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: bannerView.centerYAnchor),

            arrowIcon.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -20),
            arrowIcon.centerYAnchor.constraint(equalTo: bannerView.centerYAnchor),
            arrowIcon.widthAnchor.constraint(equalToConstant: 24),
            arrowIcon.heightAnchor.constraint(equalToConstant: 24)
        ])

        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(createBannerTapped))
        bannerView.addGestureRecognizer(tapGesture)

        return bannerView
    }

    // MARK: - Data Loading
    private func loadData() {
        guard !isLoading else { return }

        isLoading = true
        LumaTemplateService.shared.getHomeTemplates(page: currentPage) { [weak self] templateList, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let templateList = templateList {
                    if self.currentPage == 1 {
                        self.bannerTemplates = []
                        self.sectionTemplates = []
                    }

                    // 处理banner模板
                    if let bannerList = templateList.templates.first?.templateId == "banner" ? [templateList.templates.first!] : [] {
                        self.bannerTemplates = bannerList
                        self.bannerView.updateTemplates(bannerList)
                    }

                    // 处理其他模板
                    let otherTemplates = templateList.templates.filter { $0.templateId != "banner" }
                    self.sectionTemplates.append(contentsOf: otherTemplates)
                    self.hasMore = templateList.hasMore

                    self.updateSectionViews()
                } else if let error = error {
                    self.showError(error)
                }
            }
        }
    }

    private func loadMoreData() {
        guard !isLoading && hasMore else { return }

        currentPage += 1
        loadData()
    }

    // MARK: - Actions
    @objc private func proButtonTapped() {
        // 跳转到支付页面
        let payVC = PayViewController()
        presentPanModal(payVC)
    }

    @objc private func createBannerTapped() {
        // 跳转到创建页面
        guard let tabbar = TabbarViewController.tabbarVC() else { return }
        tabbar.enterCreationVc(imgCount: 1)
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension LumaHomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 下拉刷新
        let offsetY = scrollView.contentOffset.y
        if offsetY < -100 && !isLoading {
            currentPage = 1
            loadData()
        }

        // 上拉加载更多
        if scrollView.contentSize.height > 0,
           scrollView.contentOffset.y + scrollView.bounds.size.height > scrollView.contentSize.height + 50,
           hasMore && !isLoading {
            loadMoreData()
        }
    }
}

// MARK: - LumaBannerViewDelegate
extension LumaHomeViewController: LumaBannerViewDelegate {
    func bannerViewDidTapTry(_ template: LumaTemplateModel, at index: Int) {
        guard let tabbar = TabbarViewController.tabbarVC() else { return }
        tabbar.jumpToCreatePageWithTemplate(template.templateId ?? "")
    }
}

// MARK: - LumaTemplateSectionViewDelegate
extension LumaHomeViewController: LumaTemplateSectionViewDelegate {
    func templateSectionDidSelectAll(_ template: LumaTemplateModel) {
        // 跳转到模板列表页面
        let categoryListVC = CategoryListViewController()
        categoryListVC.categoryId = template.categoryId
        navigationController?.pushViewController(categoryListVC, animated: true)
    }

    func templateSectionDidSelectTemplate(_ template: LumaTemplateModel) {
        // 跳转到模板详情页面
        let detailVC = TempCreationViewController()
        // 这里需要设置模板信息
        navigationController?.pushViewController(detailVC, animated: true)
    }
}