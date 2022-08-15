import Foundation

struct VerificationModelCode {
    var items: [VerificationModelCodeItem]
}

struct VerificationModelCodeItem {
    let identifier: String
    let text: String?
}
