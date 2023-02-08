//
//  StyleDefaultColorsProvider.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import Foundation

public struct StyleDefaultColorsProvider: StyleColorsProvider {
    public var backgroundPrimary: StyleColor {
        return Asset.Colors.backgroundPrimary.color
    }
    public var backgroundSecondary: StyleColor {
        return Asset.Colors.backgroundSecondary.color
    }
    public var alwaysLight: StyleColor {
        return Asset.Colors.light.color
    }
    public var alwaysDark: StyleColor {
        return Asset.Colors.dark.color
    }
    public var accent: StyleColor {
        return Asset.Colors.darkTurquoise.color
    }
    public var textPrimary: StyleColor {
        return Asset.Colors.blueWhale.color
    }
    public var textSecondary: StyleColor {
        return Asset.Colors.battleshipGrey.color
    }
    public var success: StyleColor {
        return Asset.Colors.darkMint.color
    }
    public var attention: StyleColor {
        return Asset.Colors.orangePeel.color
    }
    public var error: StyleColor {
        return Asset.Colors.carminePink.color
    }
    public var disabled: StyleColor {
        return Asset.Colors.geyser.color
    }
    public var elementSpecial: StyleColor {
        return Asset.Colors.darkSkyBlue.color
    }

    public init() { }
}
