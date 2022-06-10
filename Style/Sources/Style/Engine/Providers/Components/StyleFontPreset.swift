//
//  StyleFontPreset.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import Foundation

/// Describes font names used by the UI components.
///
/// - Note: Instances of this type are used by ``StyleFontPreset``.
public protocol StyleFontNamePreset {
    var bold: String { get }
    var medium: String { get }
    var semibold: String { get }
    var regular: String { get }
}

/// Describes font presets used by the StyleDefaultFontsProvider.
///
/// - Note: Instances of this type are used by ``StyleDefaultFontsProvider``.
/// - Important: This type extends ``StyleFontNamePreset`` with default implementations of properties. However, you're able to override them.
public protocol StyleFontPreset: StyleFontNamePreset {
    /// Provided font family name.
    var familyName: String { get }
}

// MARK: - Default values
extension StyleFontPreset {
    public var bold: String {
        return "\(familyName)-\(FontName.bold.rawValue)"
    }

    public var medium: String {
        return "\(familyName)-\(FontName.medium.rawValue)"
    }

    public var semibold: String {
        return "\(familyName)-\(FontName.semibold.rawValue)"
    }

    public var regular: String {
        return "\(familyName)-\(FontName.regular.rawValue)"
    }
}

private enum FontName: String {
    case bold = "Bold"
    case medium = "Medium"
    case semibold = "Semibold"
    case regular = "Regular"
}
