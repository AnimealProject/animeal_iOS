import UIKit

// MARK: - Assembling
public protocol Assembling {
    static func assemble() -> UIViewController
}

// MARK: - StringProcessable
public protocol StringProcessable {
    func process(_ string: String) -> String
}
