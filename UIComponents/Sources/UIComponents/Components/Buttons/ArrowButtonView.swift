//
//  ArrowButtonView.swift
//  UIComponents
//
//  Created by Giorgi Amiranashvili on 15.01.26.
//

import UIKit

open class ArrowButtonView: ButtonView {
    private enum Constants {
        static let height: CGFloat = 16
    }
    
    public override func configure(_ model: ButtonView.Model) {
        identifier = model.identifier
        if let image = model.icon {
            let config = UIImage.SymbolConfiguration(
                font: designEngine.fonts.primary.bold(Constants.height) ?? UIFont.systemFont(ofSize: Constants.height, weight: .bold)
            )
            let boldImage = image.applyingSymbolConfiguration(config)
            contentView.setImage(boldImage, for: .normal)
            contentView.tintColor = designEngine.colors.textPrimary
        }
    }
    
    // MARK: - Setup
    public override func setup() {
        addSubview(contentView.prepareForAutoLayout())
        contentView.leadingAnchor ~= leadingAnchor
        contentView.topAnchor ~= topAnchor
        contentView.trailingAnchor ~= trailingAnchor
        contentView.bottomAnchor ~= bottomAnchor
        contentView.heightAnchor ~= Constants.height
        
        contentView.addTarget(
            self,
            action: #selector(buttonWasPressed(_:)),
            for: UIControl.Event.touchUpInside
        )
    }
}
