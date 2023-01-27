//
//  LinkOpener.swift
//  
//
//  Created by Mikhail Churbanov on 1/26/23.
//

import Foundation

public protocol LinkOpener {
    func canOpenUrl(_ url: URL) -> Bool
    func open(_ url: URL)
}
