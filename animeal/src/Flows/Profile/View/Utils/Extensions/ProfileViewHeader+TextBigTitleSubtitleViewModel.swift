// System
import Foundation

// SDK
import UIComponents

extension ProfileViewHeader {
    var model: TextBigTitleSubtitleView.Model {
        return TextBigTitleSubtitleView.Model(
            title: title,
            subtitle: subtitle
        )
    }
}
