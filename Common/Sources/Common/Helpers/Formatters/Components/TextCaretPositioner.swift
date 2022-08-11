import Foundation

public protocol CaretPositioner {
    func getCaretOffset(for text: String) -> Int
}
