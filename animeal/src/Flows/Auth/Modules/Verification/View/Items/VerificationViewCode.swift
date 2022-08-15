import Foundation

struct VerificationViewCode {
    let state: VerificationViewCodeState
    let items: [VerificationViewCodeItem]
}

struct VerificationViewCodeItem {
    let identifier: String
    let text: String?
}

enum VerificationViewCodeState {
    case normal
    case error
}
