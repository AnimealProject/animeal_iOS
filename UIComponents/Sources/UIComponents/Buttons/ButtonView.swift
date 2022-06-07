//
//  ButtonView.swift
//  UIComponents
//
//  Created by Диана Тынкован on 3.06.22.
//

import UIKit

public protocol ButtonView where Self: UIView {
    var identifier: String { get }
    var onTap: ((String) -> Void)? { get set }

    func condifure(_ model: ButtonViewModel)
}

public struct ButtonViewModel {
    public let identifier: String
    public let viewType: ButtonView.Type
    public let icon: UIImage?
    public let title: String

    public init(
        identifier: String,
        viewType: ButtonView.Type,
        icon: UIImage?,
        title: String
    ) {
        self.identifier = identifier
        self.viewType = viewType
        self.icon = icon
        self.title = title
    }
}
