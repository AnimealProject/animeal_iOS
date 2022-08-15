// System
import Foundation

// SDK
import UIComponents

extension VerificationViewHeader {
    var model: TextBigTitleSubtitleView.Model {
        TextBigTitleSubtitleView.Model(
            title: title,
            subtitle: subtitle
        )
    }
}
