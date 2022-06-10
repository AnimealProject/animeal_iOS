//
//  StyleDefaultFontsProvider.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import Foundation

public final class StyleDefaultFontsProvider: StyleFontsProviders {
    public let primary: StyleTypography
    public let secondary: StyleTypography

    public init() {
        self.primary = StyleTypography(
            StyleDefaultPrimaryFontPreset()
        )
        self.secondary = StyleTypography(
            StyleDefaultSecondaryFontPreset()
        )
        self.secondary.configurator.registerFonts()
    }
}
