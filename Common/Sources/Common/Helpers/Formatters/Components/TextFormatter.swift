import Foundation

public protocol TextFormatter {
    func format(_ unformattedText: String?) -> String?
}
