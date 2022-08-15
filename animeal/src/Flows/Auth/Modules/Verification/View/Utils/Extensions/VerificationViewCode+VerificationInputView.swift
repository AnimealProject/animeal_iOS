// System
import Foundation

// SDK
import UIComponents

extension VerificationViewCode {
    var modelState: VerificationInputView.State {
        switch state {
        case .normal:
            return VerificationInputView.State.normal
        case .error:
            return VerificationInputView.State.error
        }
    }
}

extension VerificationViewCodeItem {
    var model: VerificationInputStoreItem {
        VerificationInputStoreItem(
            identifier: identifier,
            text: text
        )
    }
}

extension VerificationInputStoreItem {
    var viewItem: VerificationViewCodeItem {
        VerificationViewCodeItem(
            identifier: identifier,
            text: text
        )
    }
}
