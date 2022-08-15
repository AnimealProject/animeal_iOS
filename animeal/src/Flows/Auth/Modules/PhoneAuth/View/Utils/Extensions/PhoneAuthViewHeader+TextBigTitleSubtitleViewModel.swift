// System
import Foundation

// SDK
import UIComponents

extension PhoneAuthViewHeader {
    var model: TextBigTitleSubtitleView.Model {
        return TextBigTitleSubtitleView.Model(
            title: title,
            subtitle: nil
        )
    }
}
