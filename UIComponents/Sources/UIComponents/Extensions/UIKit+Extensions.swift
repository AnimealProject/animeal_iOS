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

extension UITextField {
    func setPadding(_ interval: CGFloat = 18.0) {
        setLeftPadding(interval)
        setRightPadding(interval)
    }

    func setLeftPadding(_ interval: CGFloat = 18.0) {
        let paddingView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: interval,
                height: self.frame.size.height
            )
        )
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func setRightPadding(_ interval: CGFloat = 18.0) {
        let paddingView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: interval,
                height: self.frame.size.height
            )
        )
        self.rightView = paddingView
        self.rightViewMode = .always
    }

    func setLeftPaddingView(_ paddingView: UIView) {
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func setRightPaddingView(_ paddingView: UIView) {
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
