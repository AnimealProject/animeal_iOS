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
public typealias StyleFont = UIFont

public extension StyleFont {
    var font: Font {
        Font(self)
    }
}
