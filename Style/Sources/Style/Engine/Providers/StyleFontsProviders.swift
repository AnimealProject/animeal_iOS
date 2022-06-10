//
//  StyleFontsProviders.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import UIKit

/// Describes fonts used by the UI components.
///
/// - Note: Instances of this type are used by ``StyleEngine``.
/// - Important: Before using the fonts you need to register them if it necessary. 
public protocol StyleFontsProviders {
    var primary: StyleTypography { get }
    var secondary: StyleTypography { get }
}
