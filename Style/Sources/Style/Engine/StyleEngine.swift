//
//  StyleEngine.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import Foundation

/// Provides the engine that used by the UI components.
///
/// - Important: You need to use the engine in order to ensure the consistency of all design components.
open class StyleEngine: ObservableObject {
    // MARK: - Dependencies
    private let colorsProvider: StyleColorsProvider
    private let fontsProvider: StyleFontsProviders

    // MARK: - Initialization
    /// Performs engine initialization.
    ///
    /// - Parameters:
    ///   - colorsProvider: An instance providing colors.
    ///   - fontsProvider: An instance providing fonts.
    public init(
        colorsProvider: StyleColorsProvider,
        fontsProvider: StyleFontsProviders
    ) {
        self.colorsProvider = colorsProvider
        self.fontsProvider = fontsProvider
    }

    // MARK: - Accessible properties
    /// Provides colors used by the UI components.
    ///
    /// - Returns: A concrete instance of ``StyleColorsProvider`` that you can use to pick colors.
    public var colors: StyleColorsProvider {
        colorsProvider
    }

    /// Provides fonts used by the UI components.
    ///
    /// - Returns: A concrete instance of ``StyleFontsProvider`` that you can use to pick fonts.
    public var fonts: StyleFontsProviders {
        fontsProvider
    }
}
