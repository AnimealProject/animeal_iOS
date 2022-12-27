import UIKit

// MARK: - Assembling
public protocol Assembling {
    func assemble() -> UIViewController
}

// MARK: - StringProcessable
public protocol StringProcessable {
    func process(_ string: String) -> String
}
