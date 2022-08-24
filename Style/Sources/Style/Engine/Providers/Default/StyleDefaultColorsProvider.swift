//
//  StyleDefaultColorsProvider.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import Foundation

public struct StyleDefaultColorsProvider: StyleColorsProvider {
    public var backgroundPrimary: StyleColor {
        return StyleColor(Asset.Colors.backgroundPrimary.color)
    }
    public var backgroundSecondary: StyleColor {
        return StyleColor(Asset.Colors.backgroundSecondary.color)
    }
    public var alwaysLight: StyleColor {
        return StyleColor(Asset.Colors.light.color)
    }
    public var alwaysDark: StyleColor {
        return StyleColor(Asset.Colors.dark.color)
    }
    public var accent: StyleColor {
        return StyleColor(Asset.Colors.darkTurquoise.color)
    }
    public var textPrimary: StyleColor {
        return StyleColor(Asset.Colors.blueWhale.color)
    }
    public var textSecondary: StyleColor {
        return StyleColor(Asset.Colors.battleshipGrey.color)
    }
    public var success: StyleColor {
        return StyleColor(Asset.Colors.darkMint.color)
    }
    public var attention: StyleColor {
        return StyleColor(Asset.Colors.orangePeel.color)
    }
    public var error: StyleColor {
        return StyleColor(Asset.Colors.carminePink.color)
    }
    public var disabled: StyleColor {
        return StyleColor(Asset.Colors.geyser.color)
    }
    public var elementSpecial: StyleColor {
        return StyleColor(Asset.Colors.darkSkyBlue.color)
    }

    public init() { }
}
