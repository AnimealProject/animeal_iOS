import Foundation

struct VerificationModelCode {
    var items: [VerificationModelCodeItem]

    @discardableResult
    func validate() throws -> String {
        let expectedCodeDigitsCount = items.count
        let codeCandidate = items
            .compactMap { $0.text }
            .joined()

        guard codeCandidate.count == expectedCodeDigitsCount else {
            throw VerificationModelCodeError.codeDigitsCountDoesNotFit
        }
        return codeCandidate
    }
}

struct VerificationModelCodeItem {
    let identifier: String
    let text: String?
}

extension VerificationModelCode {
    enum Constants {
        static let digitsCount = 4
    }

    static func empty(digitsCount: Int = Constants.digitsCount) -> VerificationModelCode {
        VerificationModelCode(
            items: (0..<digitsCount)
                .map { _ in VerificationModelCodeItem(identifier: UUID().uuidString, text: nil) }
        )
    }
}
