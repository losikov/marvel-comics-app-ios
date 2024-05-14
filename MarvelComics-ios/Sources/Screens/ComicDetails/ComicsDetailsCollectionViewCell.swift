import Combine
import UIKit

protocol ComicsDetailsCollectionViewCellDelegate: AnyObject {
    func didTapReadNow(comic item: ComicsViewModel.Item)
    func didTapMarkAsRead(comic item: ComicsViewModel.Item)
    func didTapAddToLibrary(comic item: ComicsViewModel.Item)
    func didTapReadOffline(comic item: ComicsViewModel.Item)
}

class ComicsDetailsCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "ComicsDetailsCollectionViewCelldentifier"

    // MARK: - Properties

    weak var delegate: ComicsDetailsCollectionViewCellDelegate?
    private var item: ComicsViewModel.Item?
    private var cancellable: AnyCancellable?

    // MARK: - UI Properties

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let headerContainerView = UIView()
    private let headerStackView = UIStackView()
    private let buttonsContainerView = UIView()
    private let buttonsStackView = UIStackView()
    private let artworkImageView = UIImageView()
    private let artworkBackgroundImageView = UIImageView()
    private let readNowButton = UIButton()
    private let markAsReadButton = UIButton()
    private let addToLibraryButton = UIButton()
    private let readOfflineButton = UIButton()
    private let textContainerView = UIView()
    private let titleLabel = UILabel()
    private let titleSeparatorView = UIView()
    private let textHeaderLabel = UILabel()
    private let textLabel = UILabel()

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
        titleLabel.text = ""
        textHeaderLabel.text = ""
        textLabel.text = ""

        artworkImageView.image = #imageLiteral(resourceName: "placeholder")
        artworkBackgroundImageView.image = #imageLiteral(resourceName: "placeholder")
    }

    // MARK: - Cell Configuration

    func configure(with itemPublisher: AnyPublisher<ComicsViewModel.Item, Never>) {
        cancellable = itemPublisher.sink(receiveValue: { [weak self] item in
            self?.item = item

            self?.titleLabel.text = item.title
            self?.textHeaderLabel.text = item.name
            self?.textLabel.text = item.text

            self?.markAsReadButton.isSelected = item.markedAsRead

            if let imageUrl = item.thumbnailImageUrl {
                self?.artworkImageView.loadImageWithUrl(
                    imageUrl,
                    completionHandler: { image in
                        self?.artworkImageView.image = image
                    }
                )
            }

            if let imageUrl = item.thumbnailImageUrl {
                self?.artworkBackgroundImageView.loadImageWithUrl(
                    imageUrl,
                    completionHandler: { image in
                        self?.artworkBackgroundImageView.image = image
                    }
                )
            }
        })
    }
}

// MARK: - Actions

extension ComicsDetailsCollectionViewCell {
    @objc func readNowAction(_: UIButton) {
        guard let item = item else { return }
        delegate?.didTapReadNow(comic: item)
    }

    @objc func markAsReadAction(_: UIButton) {
        guard let item = item else { return }
        delegate?.didTapMarkAsRead(comic: item)
    }

    @objc func addToLibraryAction(_: UIButton) {
        guard let item = item else { return }
        delegate?.didTapAddToLibrary(comic: item)
    }

    @objc func readOfflineAction(_: UIButton) {
        guard let item = item else { return }
        delegate?.didTapReadOffline(comic: item)
    }
}

// MARK: - UI Setup

extension ComicsDetailsCollectionViewCell {
    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        // Main Container
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 18
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Header Container
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false

        // Background Image
        artworkBackgroundImageView.addBlur()
        artworkBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        // Artwork + Buttons Container
        headerStackView.axis = .horizontal
        headerStackView.distribution = .fill
        headerStackView.spacing = 8
        headerStackView.translatesAutoresizingMaskIntoConstraints = false

        // Artwork
        artworkImageView.contentMode = .scaleAspectFill
        artworkImageView.clipsToBounds = true
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false

        // Buttons
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fillProportionally
        buttonsStackView.spacing = 8
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false

        readNowButton.configureForAction(
            title: "READ NOW",
            fontSize: 32,
            backgroundColor: .marvelButtonBackgroundPrimary
        )
        readNowButton.addTarget(self, action: #selector(readNowAction(_:)), for: .touchUpInside)

        markAsReadButton.configureForAction(title: "MARK AS READ", fontSize: 22, imageName: "checkmark.circle.fill")
        markAsReadButton.addTarget(self, action: #selector(markAsReadAction(_:)), for: .touchUpInside)

        addToLibraryButton.configureForAction(title: "ADD TO LIBRARY", fontSize: 22, imageName: "plus.circle.fill")
        addToLibraryButton.addTarget(self, action: #selector(addToLibraryAction(_:)), for: .touchUpInside)

        readOfflineButton.configureForAction(title: "READ OFFLINE", fontSize: 22, imageName: "arrow.down.to.line")
        readOfflineButton.addTarget(self, action: #selector(readOfflineAction(_:)), for: .touchUpInside)

        // Text View
        textContainerView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.numberOfLines = 3
        titleLabel.font = .systemFont(ofSize: 32, weight: .light)
        titleLabel.textColor = .marvelLabelText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Separator
        titleSeparatorView.backgroundColor = .marvelBackgroundForth
        titleSeparatorView.translatesAutoresizingMaskIntoConstraints = false

        textHeaderLabel.font = .boldSystemFont(ofSize: 20)
        textHeaderLabel.textColor = .marvelLabelText
        textHeaderLabel.translatesAutoresizingMaskIntoConstraints = false

        textLabel.numberOfLines = 0
        textLabel.font = .systemFont(ofSize: 18, weight: .medium)
        textLabel.textColor = .marvelLabelText
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add Subviews
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        stackView.addArrangedSubview(headerContainerView)
        stackView.addArrangedSubview(textContainerView)
        stackView.addSubview(UIView())

        headerContainerView.addSubview(artworkBackgroundImageView)
        headerContainerView.addSubview(headerStackView)
        headerStackView.addArrangedSubview(artworkImageView)
        headerStackView.addArrangedSubview(buttonsContainerView)

        buttonsContainerView.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(readNowButton)
        buttonsStackView.addArrangedSubview(markAsReadButton)
        buttonsStackView.addArrangedSubview(addToLibraryButton)
        buttonsStackView.addArrangedSubview(readOfflineButton)

        textContainerView.addSubview(titleLabel)
        textContainerView.addSubview(titleSeparatorView)
        textContainerView.addSubview(textHeaderLabel)
        textContainerView.addSubview(textLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: heightAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            headerContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 320.0),
            headerContainerView.heightAnchor.constraint(lessThanOrEqualToConstant: 380.0),

            artworkBackgroundImageView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            artworkBackgroundImageView.leftAnchor.constraint(equalTo: headerContainerView.leftAnchor),
            artworkBackgroundImageView.rightAnchor.constraint(equalTo: headerContainerView.rightAnchor),
            artworkBackgroundImageView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),

            headerStackView.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 12),
            headerStackView.leftAnchor.constraint(equalTo: headerContainerView.leftAnchor, constant: 4),
            headerStackView.rightAnchor.constraint(equalTo: headerContainerView.rightAnchor, constant: -4),
            headerStackView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -12),

            artworkImageView.heightAnchor.constraint(equalTo: artworkImageView.widthAnchor, multiplier: 1.6),

            buttonsStackView.widthAnchor.constraint(equalTo: buttonsContainerView.widthAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor, constant: -6),

            markAsReadButton.heightAnchor.constraint(equalTo: addToLibraryButton.heightAnchor),
            markAsReadButton.heightAnchor.constraint(equalTo: readOfflineButton.heightAnchor),
            readNowButton.heightAnchor.constraint(greaterThanOrEqualTo: markAsReadButton.heightAnchor, multiplier: 1.4),

            titleLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -4),

            titleSeparatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            titleSeparatorView.heightAnchor.constraint(equalToConstant: 1.0),
            titleSeparatorView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10.0),
            titleSeparatorView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),

            textHeaderLabel.topAnchor.constraint(equalTo: titleSeparatorView.bottomAnchor, constant: 20),
            textHeaderLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 8),
            textHeaderLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -4),

            textLabel.topAnchor.constraint(equalTo: textHeaderLabel.bottomAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -4),
            textLabel.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),
        ])
    }
}

private extension UIButton {
    func configureForAction(
        title: String,
        fontSize: CGFloat,
        backgroundColor: UIColor = .marvelButtonBackgroundSecondary,
        imageName: String? = nil
    ) {
        let color: UIColor = .marvelButtonTitleEnabled
        let font: UIFont = .marvelRegular(ofSize: fontSize)

        // Title
        var attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.kern: 1.3,
        ]
        attributes[NSAttributedString.Key.foregroundColor] = color
        setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)

        attributes[NSAttributedString.Key.foregroundColor] = color.withAlphaComponent(0.8)
        setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .highlighted)

        // Background
        setBackgroundImage(backgroundColor.image(), for: .normal)
        setBackgroundImage(backgroundColor.withAlphaComponent(0.8).image(), for: .highlighted)

        // Image
        if let imageName = imageName,
           let icon = UIImage(
               systemName: imageName,
               withConfiguration: UIImage.SymbolConfiguration(font: font, scale: .small)
           )
        {
            func renderImage(with iconColor: UIColor) -> UIImage {
                let imageSize = CGSize(width: 12 + icon.size.width + 9 + 12, height: 30)
                let renderer = UIGraphicsImageRenderer(size: imageSize)
                let image = renderer.image { context in
                    icon.withTintColor(iconColor).draw(
                        at: .init(
                            x: 12,
                            y: (imageSize.height - icon.size.height) / 2.0
                        )
                    )
                    context.cgContext.setFillColor(color.withAlphaComponent(0.2).cgColor)
                    context.fill(
                        .init(x: 12 + icon.size.width + 9 - 2, y: 0, width: 2, height: imageSize.height)
                    )
                }
                .withRenderingMode(.alwaysOriginal)
                .withAlignmentRectInsets(.init(top: 4, left: 0, bottom: 0, right: 0))
                return image
            }

            setImage(renderImage(with: color), for: .normal)
            setImage(renderImage(with: color.withAlphaComponent(0.8)), for: .highlighted)
            setImage(renderImage(with: .marvelButtonTitleSelected), for: .selected)

            contentHorizontalAlignment = .left
        } else {
            setImage(nil, for: .normal)
            contentHorizontalAlignment = .center
        }
    }
}

private extension UIView {
    func addBlur(_ alpha: CGFloat = 0.7) {
        let effect = UIBlurEffect(style: .prominent)
        let effectView = UIVisualEffectView(effect: effect)

        effectView.frame = bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = alpha

        addSubview(effectView)
    }
}

private extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
