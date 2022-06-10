//
//  StyleFontConfigurator.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import Foundation
import CoreText

/// Provides an ability to register fonts used by the UI components.
///
/// - Note: Instances of this type are used by ``StyleFontsProviders``.
public final class StyleFontConfigurator {
    private let preset: StyleFontPreset

    // MARK: - Initialization
    /// Performs configurator initialization.
    ///
    /// - Parameters:
    ///   - preset: A preset that contains appropriate information to complete fonts registration.
    public init(_ preset: StyleFontPreset) {
        self.preset = preset
    }

    /// Registrates fonts used by the UI components.
    ///
    /// - Important: Call this method to make design fonts work.
    public func registerFonts() {
        registerFont(fontName: preset.bold)
        registerFont(fontName: preset.medium)
        registerFont(fontName: preset.semibold)
        registerFont(fontName: preset.regular)
    }

    private func registerFont(
        bundle: Bundle = .module,
        fontName: String,
        fontExtension: String = "ttf"
    ) {
        guard
            let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
            let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
            let font = CGFont(fontDataProvider)
        else {
            fatalError(
                "Couldn't create font from filename: \(fontName) with extension \(fontExtension)"
            )
        }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}
