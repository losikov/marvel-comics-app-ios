import Combine
import UIKit

class ComicsCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "ComicsCollectionViewCellIdentifier"

    // MARK: - Properties

    var imageViewTag: URL?

    // MARK: - UI Properties

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView()
    private var cancellable: AnyCancellable?

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

    // MARK: - prepareForReuse

    override func prepareForReuse() {
        titleLabel.textColor = .darkText
        titleLabel.text = ""
        imageViewTag = nil
        imageView.image = #imageLiteral(resourceName: "placeholder")
        activityIndicator.stopAnimating()
    }

    // MARK: - Cell Configuration

    func configure(with itemPublisher: AnyPublisher<ComicsViewModel.Item, Never>) {
        cancellable = itemPublisher.sink { [weak self] item in
            self?.titleLabel.text = item.title

            if let imageUrl = item.thumbnailImageUrl {
                self?.imageViewTag = imageUrl
                self?.imageView.loadImageWithUrl(
                    imageUrl,
                    startedHandler: {
                        self?.activityIndicator.startAnimating()
                    },
                    completionHandler: { image in
                        if self?.imageViewTag == imageUrl {
                            self?.titleLabel.textColor = .white
                            self?.activityIndicator.stopAnimating()
                            self?.imageView.image = image
                        }
                    }
                )
            }
        }
    }

    func setHighligted(_ highlighted: Bool) {
        imageView.alpha = highlighted ? 0.8 : 1.0
    }
}

// MARK: - UI Setup

extension ComicsCollectionViewCell {
    private func setupViews() {
        // Content View
        contentView.isUserInteractionEnabled = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = .imageRadius
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = .imageRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .darkText
        titleLabel.clipsToBounds = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Activity Indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        // Add Subviews
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(titleLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),

            titleLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -3),
            titleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),

            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
