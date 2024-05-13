import UIKit

extension UIColor {
    static var marvelButtonTitleEnabled: UIColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
    static var marvelButtonTitleDiabled: UIColor = .init(red: 93 / 255.0, green: 93 / 255.0, blue: 93 / 255.0, alpha: 1)
    static var marvelButtonBackgroundPrimary: UIColor = .init(
        red: 107 / 255.0,
        green: 64 / 255.0,
        blue: 156 / 255.0,
        alpha: 1
    )
    static var marvelButtonBackgroundSecondary: UIColor = .init(
        red: 34 / 255.0,
        green: 34 / 255.0,
        blue: 34 / 255.0,
        alpha: 1
    )
    static var marvelButtonTitleSelected: UIColor = .init(
        red: 93 / 255.0,
        green: 194 / 255.0,
        blue: 77 / 255.0,
        alpha: 1
    )

    static var marvelBackgroundPrimary: UIColor = .init(red: 33 / 255.0, green: 33 / 255.0, blue: 33 / 255.0, alpha: 1)
    static var marvelBackgroundSecondary: UIColor = .init(
        red: 34 / 255.0,
        green: 34 / 255.0,
        blue: 34 / 255.0,
        alpha: 1
    )
    static var marvelBackgroundThird: UIColor = .init(red: 44 / 255.0, green: 44 / 255.0, blue: 44 / 255.0, alpha: 1)
    static var marvelBackgroundForth: UIColor = .init(red: 76 / 255.0, green: 76 / 255.0, blue: 76 / 255.0, alpha: 1)

    static var marvelLabelPrimary: UIColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
    static var marvelLabelSecondary: UIColor = .init(red: 220 / 255.0, green: 220 / 255.0, blue: 220 / 255.0, alpha: 1)
    static var marvelLabelText: UIColor = .init(red: 199 / 255.0, green: 199 / 255.0, blue: 199 / 255.0, alpha: 1)

    static var marvelLabelStatus: UIColor = .dynamicColor(
        light: .darkText,
        dark: .lightText
    )

    public class func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor {
            switch $0.userInterfaceStyle {
            case .dark: return dark
            default: return light
            }
        }
    }
}
