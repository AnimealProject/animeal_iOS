import UIKit

protocol ScreenAccessible: UIViewController {
    static var screenIdentifier: String { get }
}

extension ScreenAccessible {
    func applyScreenIdentifier() {
        view.accessibilityIdentifier = Self.screenIdentifier
    }
}
