import UIKit

extension UIFont {
    static var marvelButtonsToolbar: UIFont = .init(
        name: .marvelRegular,
        size: 28
    ) ?? .systemFont(ofSize: 28)

    static func marvelRegular(ofSize fontSize: CGFloat) -> UIFont {
        UIFont(name: .marvelRegular, size: fontSize) ?? .systemFont(ofSize: fontSize)
    }
}

// MARK: - Font names

extension String {
    static let marvelRegular: String = "Marvel Regular"
}
