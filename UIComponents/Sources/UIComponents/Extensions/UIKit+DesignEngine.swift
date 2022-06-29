//
//  UIKit+Extensions.swift
//  UIComponents
//
//  Created by Диана Тынкован on 10.06.22.
//

import Style
import UIKit

private let defaultDesignEngine = StyleDefaultEngine()

public extension UIView {
    var designEngine: StyleEngine {
        defaultDesignEngine
    }
}

public extension UIViewController {
    var designEngine: StyleEngine {
        defaultDesignEngine
    }
}
