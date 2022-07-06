//
//  UIKit+Extensions.swift
//  UIComponents
//
//  Created by Диана Тынкован on 10.06.22.
//

import Style
import UIKit

private let defaultDesignEngine = StyleDefaultEngine()

public protocol StyleEngineContainable {
    var designEngine: StyleEngine { get }
}

public extension StyleEngineContainable {
    var designEngine: StyleEngine {
        defaultDesignEngine
    }
}

extension UIView: StyleEngineContainable {}
extension UIViewController: StyleEngineContainable {}
