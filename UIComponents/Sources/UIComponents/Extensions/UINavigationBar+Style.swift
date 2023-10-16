//
//  UINavigationBar+Style.swift
//  
//
//  Created by Kiryl Budzevich on 8.02.23.
//

import UIKit
import Style

extension Style<UINavigationBar> {
    public static var `default`: Self {
        .init { bar in
            bar.prefersLargeTitles = false
            bar.isTranslucent = false
            bar.tintColor = bar.designEngine.colors.textPrimary
            bar.titleTextAttributes = [:]
            bar.largeTitleTextAttributes = [:]
            bar.backIndicatorImage = Asset.Images.arrowBackOffset.image
            bar.backIndicatorTransitionMaskImage = Asset.Images.arrowBackOffset.image

            UINavigationBar.appearance().applyAppearanceForAllStates({
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = bar.designEngine.colors.backgroundPrimary
                appearance.shadowImage = UIImage()
                appearance.shadowColor = .none
                appearance.largeTitleTextAttributes = bar.largeTitleTextAttributes ?? [:]
                appearance.titleTextAttributes = bar.titleTextAttributes ?? [:]
                appearance.setBackIndicatorImage(bar.backIndicatorImage, transitionMaskImage: bar.backIndicatorTransitionMaskImage)
                return appearance
            }())
        }
    }
}

extension UIBarButtonItem {
    public static func back(target: Any?, action: Selector?) -> UIBarButtonItem {
        UIBarButtonItem(image: UINavigationBar.appearance().backIndicatorImage, style: .plain, target: target, action: action)
    }
}

extension UINavigationBar {
    func applyAppearanceForAllStates(_ appearance: UINavigationBarAppearance) {
        standardAppearance = appearance
        compactAppearance = appearance
        scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            compactScrollEdgeAppearance = appearance
        }
    }
}
