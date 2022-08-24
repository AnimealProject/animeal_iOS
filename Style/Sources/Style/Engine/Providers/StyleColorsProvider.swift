//
//  StyleColorsProvider.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import Foundation

/// Describes color names used by the UI components.
///
/// - Note: Instances of this type are used by ``StyleEngine``.
public protocol StyleColorsProvider {
    var backgroundPrimary: StyleColor { get }
    var backgroundSecondary: StyleColor { get }
    var alwaysLight: StyleColor { get }
    var alwaysDark: StyleColor { get }
    var accent: StyleColor { get }
    var textPrimary: StyleColor { get }
    var textSecondary: StyleColor { get }
    var success: StyleColor { get }
    var attention: StyleColor { get }
    var error: StyleColor { get }
    var disabled: StyleColor { get }
    var elementSpecial: StyleColor { get }
}
