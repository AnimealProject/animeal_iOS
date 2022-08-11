//
//  StyleColor.swift
//  Style
//
//  Created by Диана Тынкован on 8.06.22.
//

import UIKit
import SwiftUI

/// Describes color used by the UI components.
///
/// - Note: Instances of this type are used by ``StyleColorsProvider``.
public final class StyleColor {
    /// Provides an instance of UIColor if the instanstance already exists.
    ///
    /// - Returns: A concrete instance of ``UIColor``.
    public let uiColor: UIColor

    /// Provides an instance of CGColor if the instanstance already exists.
    ///
    /// - Returns: A concrete instance of ``CGColor``.
    public let cgColor: CGColor

    /// Provides an instance of Color.
    ///
    /// - Returns: A concrete instance of ``Color``.
    public var color: Color {
        return Color(uiColor)
    }

    /// Performs initialization with the provided instance of UIColor.
    ///
    /// - Parameters:
    ///   - uiColor:  A concrete instance of ``UIColor``.
    public init(_ uiColor: UIColor) {
        self.uiColor = uiColor
        self.cgColor = uiColor.cgColor
    }
}
