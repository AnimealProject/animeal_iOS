import Foundation

public protocol TextInputFormatter {
    func formatInput(currentText: String, range: NSRange, replacementString text: String) -> TextFormattedValue
}
