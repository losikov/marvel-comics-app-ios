import UIKit

class ComicsCollectionViewLoadingMoreCell: UICollectionViewCell {
    static let cellIdentifier = "ComicsCollectionViewLoadingMoreCellIdentifier"

    // MARK: - UI Properties

    private let activityIndicator = UIActivityIndicatorView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Cell Configuration

    func configure() {
        activityIndicator.startAnimating()
    }
}

// MARK: - UI Setup

extension ComicsCollectionViewLoadingMoreCell {
    private func setupViews() {
        // Content View
        contentView.isUserInteractionEnabled = false
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = .imageRadius
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        // Add Subviews
        contentView.addSubview(activityIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),

            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
