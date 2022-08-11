import Foundation

public protocol TextUnformatter {
    func unformat(_ formattedText: String?) -> String?
}
