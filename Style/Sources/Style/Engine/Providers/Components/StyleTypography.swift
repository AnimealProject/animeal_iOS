//
//  StyleTypography.swift
//  Style
//
//  Created by Диана Тынкован on 9.06.22.
//

import UIKit

/// Describes typography used by the UI components.
///
/// - Note: Instances of this type are used by ``StyleFontsProviders``.
public final class StyleTypography {
    /// Prepared configurator you can use to complete registration if it necessary.
    ///
    /// - Note: It's only a get property calculated based on the given preset.
    public var configurator: StyleFontConfigurator {
        StyleFontConfigurator(preset)
    }

    /// Contains appropriate information about fonts family and styles.
    public let preset: StyleFontPreset

    /// Performs typography initialization.
    ///
    /// - Parameters:
    ///   - preset: A preset that contains appropriate information about fonts family and styles.
    public init(_ preset: StyleFontPreset) {
        self.preset = preset
    }

    /// Provides an instance of StyleFont in a bold style that contains concreate UIFont or Font you need.
    ///
    /// - Returns: A concrete instance of ``StyleFont``.
    public func bold(_ size: CGFloat) -> StyleFont {
        let uiFont = UIFont(name: preset.bold, size: size)
        return StyleFont(uiFont)
    }

    /// Provides an instance of StyleFont in a medium style that contains concreate UIFont or Font you need.
    ///
    /// - Returns: A concrete instance of ``StyleFont``.
    public func medium(_ size: CGFloat) -> StyleFont {
        let uiFont = UIFont(name: preset.medium, size: size)
        return StyleFont(uiFont)
    }

    /// Provides an instance of StyleFont in a semibold style that contains concreate UIFont or Font you need.
    ///
    /// - Returns: A concrete instance of ``StyleFont``.
    public func semibold(_ size: CGFloat) -> StyleFont {
        let uiFont = UIFont(name: preset.semibold, size: size)
        return StyleFont(uiFont)
    }

    /// Provides an instance of StyleFont in a regular style that contains concreate UIFont or Font you need.
    ///
    /// - Returns: A concrete instance of ``StyleFont``.
    public func regular(_ size: CGFloat) -> StyleFont {
        let uiFont = UIFont(name: preset.regular, size: size)
        return StyleFont(uiFont)
    }
}
