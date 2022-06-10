//
//  StyleDefaultTypographies.swift
//  Style
//
//  Created by Диана Тынкован on 10.06.22.
//

import Foundation

struct StyleDefaultPrimaryFontPreset: StyleFontPreset {
    let familyName: String = "HelveticaNeue"
    let bold: String = "HelveticaNeue-Bold"
    let medium: String = "HelveticaNeue-Medium"
    let semibold: String = "HelveticaNeue-Light"
    let regular: String = "HelveticaNeue-Thin"
}

struct StyleDefaultSecondaryFontPreset: StyleFontPreset {
    let familyName: String = "SFProDisplay"
}
