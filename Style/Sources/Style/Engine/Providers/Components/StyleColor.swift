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
public typealias StyleColor = UIColor

public extension StyleColor {
    var color: Color {
        Color(self)
    }
}
