import Combine
import UIKit

class ComicsCollectionViewController: UIViewController {
    // MARK: - Properties

    private let viewModel = ComicsViewModel()
    private var count: Int = 0

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - UI Properties

    private let logo = UIImageView()
    private let searchController = UISearchController(searchResultsController: nil)

    private static let compositionalLayout = UICollectionViewCompositionalLayout(
        sectionProvider: {
            _, environment -> NSCollectionLayoutSection? in
            let margin: CGFloat = 10
            let padding: CGFloat = 10
            let cellMinWidth: CGFloat = 145
            let cellRatio: CGFloat = 1.6

            let cellWidth = {
                let h = environment.container.effectiveContentSize.height
                let contentWidth = environment.container.effectiveContentSize.width - (2 * margin)
                let count = floor(contentWidth / cellMinWidth)
                let innerSpacing = (count - 1) * padding
                return (contentWidth - innerSpacing) / count
            }()
            let cellHeight = cellWidth * cellRatio
            let cellMaxCountInRow = environment.container.effectiveContentSize.width / cellWidth

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(cellWidth),
                heightDimension: .fractionalHeight(1)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(cellHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(padding)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = padding
            section.contentInsets = .init(
                top: margin,
                leading: margin,
                bottom: margin,
                trailing: margin
            )

            return section
        }
    )

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)

    private let loadingView = UILabel()
    private let noResultsView = UILabel()

    private let errorStackView = UIStackView()
    private let errorHeaderLabel = UILabel()
    private let errorDescriptionLabel = UILabel()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
        setupViewModel()

        viewModel.search("", offset: 0)
    }
}

// MARK: - UI Setup

extension ComicsCollectionViewController {
    private func setupViews() {
        // Logo
        logo.contentMode = .scaleAspectFit
        logo.image = #imageLiteral(resourceName: "Logo")
        navigationItem.titleView = logo

        // Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Comics"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // Collection View
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            ComicsCollectionViewCell.self,
            forCellWithReuseIdentifier: ComicsCollectionViewCell.cellIdentifier
        )
        collectionView.register(
            ComicsCollectionViewLoadingMoreCell.self,
            forCellWithReuseIdentifier: ComicsCollectionViewLoadingMoreCell.cellIdentifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        // Refresh Control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        // Loading View
        loadingView.text = "Loading..."
        loadingView.font = .marvelRegular(ofSize: 34)
        loadingView.textAlignment = .center
        loadingView.textColor = .marvelLabelText
        loadingView.isHidden = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        // No Results View
        noResultsView.numberOfLines = 0
        noResultsView.text = """
        Ooops... No Results.
        Try Another Name...
        """
        noResultsView.font = .marvelRegular(ofSize: 34)
        noResultsView.textAlignment = .center
        noResultsView.textColor = .marvelLabelText
        noResultsView.isHidden = true
        noResultsView.translatesAutoresizingMaskIntoConstraints = false

        // Error View
        errorStackView.axis = .vertical
        errorStackView.alignment = .center
        errorStackView.spacing = 8
        errorStackView.isHidden = true
        errorStackView.translatesAutoresizingMaskIntoConstraints = false

        errorHeaderLabel.text = "Please Try Again Later..."
        errorHeaderLabel.font = .marvelRegular(ofSize: 27)
        errorHeaderLabel.textAlignment = .center
        errorHeaderLabel.textColor = .marvelLabelText

        errorDescriptionLabel.font = .marvelRegular(ofSize: 18)
        errorDescriptionLabel.textAlignment = .center
        errorDescriptionLabel.textColor = .marvelLabelText
        errorDescriptionLabel.numberOfLines = 0

        // Add Subviews
        view.addSubview(collectionView)
        view.addSubview(loadingView)
        view.addSubview(noResultsView)
        errorStackView.addArrangedSubview(errorHeaderLabel)
        errorStackView.addArrangedSubview(errorDescriptionLabel)
        view.addSubview(errorStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            noResultsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            errorStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
        ])
    }

    private func setupViewModel() {
        viewModel.count
            .sink { [weak self] count in
                self?.count = count
                self?.collectionView.reloadSections(IndexSet(integer: 0))
            }
            .store(in: &cancellables)

        viewModel.$state
            .sink { [weak self] state in
                switch state {
                case .loading:
                    self?.loadingView.isHidden = false
                    self?.noResultsView.isHidden = true
                    self?.errorStackView.isHidden = true
                case .data, .loadingMoreData:
                    self?.loadingView.isHidden = true
                    self?.noResultsView.isHidden = true
                    self?.errorStackView.isHidden = true
                case .noData:
                    self?.loadingView.isHidden = true
                    self?.noResultsView.isHidden = false
                    self?.errorStackView.isHidden = true
                case let .error(message):
                    self?.loadingView.isHidden = true
                    self?.noResultsView.isHidden = true
                    self?.errorStackView.isHidden = false

                    self?.errorDescriptionLabel.text = message
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - UISearchResultsUpdating

extension ComicsCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        viewModel.search(text, offset: 0)
    }
}

// MARK: - UICollectionViewDataSource

extension ComicsCollectionViewController: UICollectionViewDataSource {
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
                withReuseIdentifier: ComicsCollectionViewCell.cellIdentifier,
                for: indexPath
            ) as! ComicsCollectionViewCell
            cell.configure(with: item)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ComicsCollectionViewLoadingMoreCell.cellIdentifier,
            for: indexPath
        ) as! ComicsCollectionViewLoadingMoreCell
        cell.configure()
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ComicsCollectionViewController: UICollectionViewDelegate {
    func collectionView(
        _: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if let _ = viewModel.item(at: indexPath.row) {
            viewModel.currentIndex = indexPath.item
            let vc = ComicsDetailsCollectionViewController(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didHighlightItemAt indexPath: IndexPath
    ) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ComicsCollectionViewCell {
            cell.setHighligted(true)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didUnhighlightItemAt indexPath: IndexPath
    ) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ComicsCollectionViewCell {
            cell.setHighligted(false)
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension ComicsCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(
        _: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        for indexPath in indexPaths {
            viewModel.prefetch(at: indexPath.item)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ComicsCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(
        _: UIScrollView,
        willDecelerate _: Bool
    ) {
        switch viewModel.state {
        case .loading:
            ()
        default:
            collectionView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Actions

extension ComicsCollectionViewController {
    @objc func refreshAction(refreshControl _: UIRefreshControl) {
        viewModel.search("", offset: 0)
    }
}
