//
//  StyleDefaultColorsProvider.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import Foundation

public struct StyleDefaultColorsProvider: StyleColorsProvider {
    public var primary: StyleColor {
        StyleColor(Asset.Colors.light.color)
    }
    public var secondary: StyleColor {
        StyleColor(Asset.Colors.desertStorm.color)
    }
    public var textPrimary: StyleColor {
        StyleColor(Asset.Colors.dark.color)
    }
    public var textSecondary: StyleColor {
        StyleColor(Asset.Colors.blueWhale.color)
    }
    public var textDescriptive: StyleColor {
        StyleColor(Asset.Colors.osloGrey.color)
    }
    public var accentTint: StyleColor {
        StyleColor(Asset.Colors.darkTurquoise.color)
    }
    public var secondaryAccentTint: StyleColor {
        StyleColor(Asset.Colors.darkSkyBlue.color)
    }
    public var disableTint: StyleColor {
        StyleColor(Asset.Colors.battleshipGrey.color)
    }
    public var destructive: StyleColor {
        StyleColor(Asset.Colors.carminePink.color)
    }
    public var alwaysLight: StyleColor {
        StyleColor(Asset.Colors.light.color)
    }
    public var alwaysDark: StyleColor {
        StyleColor(Asset.Colors.dark.color)
    }
    public var success: StyleColor {
        StyleColor(Asset.Colors.darkMint.color)
    }
    public var attention: StyleColor {
        StyleColor(Asset.Colors.orangePeel.color)
    }
    public var error: StyleColor {
        StyleColor(Asset.Colors.watermelon.color)
    }

    public init() { }
}
