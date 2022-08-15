// System
import Foundation

// SDK
import UIComponents
import Style

extension VereficationViewResendCode {
    var model: TextClickableLeftIconTitleView.Model {
        TextClickableLeftIconTitleView.Model(
            icon: Asset.Images.refreshIcon.image,
            title: title,
            subtitle: timeLeft
        )
    }
}
