import SwiftUI
import Style
import UIComponents

enum FeedingCapsuleButtonFactory {
    static func filled(title: String, style: StyleEngine, action: @escaping () -> Void) -> CapsuleButton {
        CapsuleButton(
            title: title,
            font: style.fonts.primary.bold(16).font,
            foregroundColor: style.colors.alwaysLight.color,
            backgroundColor: style.colors.accent.color,
            borderColor: style.colors.accent.color,
            height: 60,
            action: action
        )
    }

    static func outlined(title: String, style: StyleEngine, action: @escaping () -> Void) -> CapsuleButton {
        CapsuleButton(
            title: title,
            font: style.fonts.primary.bold(16).font,
            foregroundColor: style.colors.accent.color,
            backgroundColor: style.colors.alwaysLight.color,
            borderColor: style.colors.accent.color,
            height: 60,
            action: action
        )
    }
}
