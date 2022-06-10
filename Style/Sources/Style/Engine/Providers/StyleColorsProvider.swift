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
    var primary: StyleColor { get }
    var secondary: StyleColor { get }
    var textPrimary: StyleColor { get }
    var textSecondary: StyleColor { get }
    var textDescriptive: StyleColor { get }
    var accentTint: StyleColor { get }
    var disableTint: StyleColor { get }
    var destructive: StyleColor { get }
}
