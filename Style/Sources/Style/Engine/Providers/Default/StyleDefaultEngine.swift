//
//  StyleDefaultEngine.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import Foundation

public final class StyleDefaultEngine: StyleEngine {
    public init() {
        super.init(
            colorsProvider: StyleDefaultColorsProvider(),
            fontsProvider: StyleDefaultFontsProvider()
        )
    }
}
