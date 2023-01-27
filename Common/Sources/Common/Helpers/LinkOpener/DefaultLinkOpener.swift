//
//  DefaultLinkOpener.swift
//  
//
//  Created by Mikhail Churbanov on 1/26/23.
//

import UIKit

public final class DefaultLinkOpener: LinkOpener {

    public init() {
    }

    public func canOpenUrl(_ url: URL) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }

    public func open(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
