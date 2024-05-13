import Combine
import UIKit

class ComicsDetailsCollectionViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: ComicsViewModel
    private var count: Int = 0
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - UI Properties

    static func compositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPaging

        let config = UICollectionViewCompositionalLayoutConfiguration()

        let layout = UICollectionViewCompositionalLayout(section: layoutSection, configuration: config)
        return layout
    }

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout())

    private let previousButton = UIButton()
    private let nextButton = UIButton()

    // MARK: - Initialization

    init(viewModel: ComicsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.hidesBackButton = true
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.toolbar.barTintColor = .marvelBackgroundPrimary
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setToolbarHidden(true, animated: true)
    }
}

// MARK: - UI Setup

extension ComicsDetailsCollectionViewController {
    private func setupUI() {
        // Navigation Bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(backAction(sender:))
        )
        navigationItem.rightBarButtonItem?.tintColor = .marvelButtonTitleEnabled

        // Collection View
        collectionView.register(
            ComicsDetailsCollectionViewCell.self,
            forCellWithReuseIdentifier: ComicsDetailsCollectionViewCell.cellIdentifier
        )
        collectionView.register(
            ComicsDetailsCollectionViewLoadingMoreCell.self,
            forCellWithReuseIdentifier: ComicsDetailsCollectionViewLoadingMoreCell.cellIdentifier
        )
        collectionView.backgroundColor = .marvelBackgroundPrimary
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self

        // Toolbar
        previousButton.configureForToolbar(title: "PREVIOUS", imageName: "chevron.compact.backward", leading: true)
        previousButton.addTarget(self, action: #selector(previousAction(sender:)), for: .touchUpInside)

        nextButton.configureForToolbar(title: "NEXT", imageName: "chevron.compact.forward", leading: false)
        nextButton.addTarget(self, action: #selector(nextAction(sender:)), for: .touchUpInside)

        setToolbarItems(
            [
                .fixedSpace(1),
                .init(customView: previousButton),
                .flexibleSpace(),
                .init(customView: nextButton),
                .fixedSpace(1),
            ],
            animated: false
        )

        // Add Subviews
        view.addSubview(collectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupViewModel() {
        viewModel.count
            .sink(receiveValue: { [weak self] count in
                self?.count = count
                self?.collectionView.reloadData()

                if let currentIndex = self?.viewModel.currentIndex {
                    let indexPath = IndexPath(item: currentIndex, section: 0)
                    self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                }
            })
            .store(in: &cancellables)

        viewModel.$state
            .sink { [weak self] state in
                if case let .error(message) = state {
                    let alert = UIAlertController(
                        title: "Error",
                        message: message,
                        preferredStyle: UIAlertController.Style.alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Actinos

extension ComicsDetailsCollectionViewController {
    @objc func backAction(sender _: AnyObject) {
        navigationController?.popViewController(animated: true)
    }

    @objc func previousAction(sender _: AnyObject) {
        guard viewModel.currentIndex > 0 else {
            return
        }

        let indexPath = IndexPath(item: viewModel.currentIndex - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    @objc func nextAction(sender _: AnyObject) {
        guard viewModel.currentIndex < count - 1 else {
            return
        }

        let indexPath = IndexPath(item: viewModel.currentIndex + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension ComicsDetailsCollectionViewController: UICollectionViewDataSource {
    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        return count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if let item = viewModel.item(at: indexPath.row) {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ComicsDetailsCollectionViewCell.cellIdentifier,
                for: indexPath
            ) as! ComicsDetailsCollectionViewCell
            cell.configure(with: item)
            cell.delegate = self
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ComicsDetailsCollectionViewLoadingMoreCell.cellIdentifier,
            for: indexPath
        ) as! ComicsDetailsCollectionViewLoadingMoreCell
        cell.configure()
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ComicsDetailsCollectionViewController: UICollectionViewDelegate {
    func collectionView(
        _: UICollectionView,
        willDisplay _: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        previousButton.isEnabled = indexPath.item != 0
        nextButton.isEnabled = viewModel.currentIndex < count - 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying _: UICollectionViewCell,
        forItemAt _: IndexPath
    ) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else {
            return
        }
        viewModel.currentIndex = indexPath.item
    }
}

// MARK: - ComicsDetailsCollectionViewCellDelegate

extension ComicsDetailsCollectionViewController: ComicsDetailsCollectionViewCellDelegate {
    func didTapReadNow(comic item: ComicsViewModel.Item) {
        guard let url = item.publicUrl, UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func didTapMarkAsRead(comic item: ComicsViewModel.Item) {
        viewModel.markAsRead(item)
    }

    func didTapAddToLibrary(comic _: ComicsViewModel.Item) {
        let alert = UIAlertController(
            title: "Try Another Time",
            message: "Add To Library is not implemented yet.",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func didTapReadOffline(comic _: ComicsViewModel.Item) {
        let alert = UIAlertController(
            title: "Try Another Time",
            message: "Read Offline is not implemented yet.",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

private extension UIButton {
    func configureForToolbar(
        title: String,
        imageName: String,
        leading: Bool
    ) {
        let colorEnabled: UIColor = .marvelButtonTitleEnabled
        let colorDisabled: UIColor = .marvelButtonTitleDiabled
        let font: UIFont = .marvelButtonsToolbar

        // Title
        var attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.kern: 1.2,
        ]

        attributes[NSAttributedString.Key.foregroundColor] = colorEnabled
        setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)

        attributes[NSAttributedString.Key.foregroundColor] = colorEnabled.withAlphaComponent(0.8)
        setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .highlighted)

        attributes[NSAttributedString.Key.foregroundColor] = colorDisabled
        setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .disabled)

        // Image
        var config = UIButton.Configuration.plain()
        config.imagePlacement = leading ? .leading : .trailing
        config.imagePadding = 8
        configuration = config

        if let icon = UIImage(
            systemName: imageName,
            withConfiguration: UIImage.SymbolConfiguration(font: font, scale: .small)
        )?.withRenderingMode(.alwaysOriginal) {
            let imageSize = CGSize(width: icon.size.width, height: 30)
            let renderer = UIGraphicsImageRenderer(size: imageSize)
            let image = renderer.image { _ in
                icon.draw(
                    at: .init(
                        x: 0,
                        y: (imageSize.height - icon.size.height) / 2.0 - 2
                    )
                )
            }
            setImage(image.withTintColor(colorEnabled), for: .normal)
            setImage(image.withTintColor(colorEnabled.withAlphaComponent(0.8)), for: .highlighted)
            setImage(image.withTintColor(colorDisabled), for: .disabled)

            contentHorizontalAlignment = leading ? .left : .right
        }
    }
}
