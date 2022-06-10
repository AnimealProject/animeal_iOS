//
//  StyleFont.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import UIKit
import SwiftUI

/// Describes font used by the UI components.
///
/// - Note: Instances of this type are used by ``StyleFontsProviders``.
public class StyleFont {
    /// Provides an instance of UIFont if the instanstance already exists.
    ///
    /// - Returns: A concrete instance of ``UIFont`` if it exists otherwise nil.
    public let uiFont: UIFont?

    /// Provides an instance of Font if the instanstance already exists.
    ///
    /// - Returns: A concrete instance of ``Font`` if it exists otherwise nil.
    public var font: Font? {
        guard let uiFont = uiFont else {
            return nil
        }
         return Font(uiFont)
    }

    /// Performs initialization with the provided instance of UIFont.
    ///
    /// - Parameters:
    ///   - uiFont:  A concrete instance of ``UIFont`` if it exists otherwise nil.
    public init(_ uiFont: UIFont?) {
        self.uiFont = uiFont
    }
}
