//
//  LinkLabel.swift
//  UIComponents
//
//  Created by Sebastián Fernández on 9/5/25.
//

import UIKit

// SDK
import Common

public extension LinkLabel {
    struct Link {
        public let range: NSRange
        public let identifier: String

        public init(
            range: NSRange,
            identifier: String
        ) {
            self.range = range
            self.identifier = identifier
        }
    }
}

public final class LinkLabel: UILabel {
    var links: [Link] = []
    public var linkTapHandler: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = true
    }

    // configure attributedText and links in one place
    public func configure(text: String, termsRange: NSRange, privacyRange: NSRange) {
        let attributed = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor: designEngine.colors.textPrimary,
            .font: designEngine.fonts.primary.light(14)
        ])
        let accentColor = designEngine.colors.accent

        // Style links
        attributed.addAttributes(
            [.foregroundColor: accentColor, .underlineStyle: NSUnderlineStyle.single.rawValue],
            range: termsRange
        )
        attributed.addAttributes(
            [.foregroundColor: accentColor, .underlineStyle: NSUnderlineStyle.single.rawValue],
            range: privacyRange
        )

        // Set text
        self.attributedText = attributed

        // Save link ranges/identifiers
        links = [
            Link(range: termsRange, identifier: Constants.URLs.termsAndConditions),
            Link(range: privacyRange, identifier: Constants.URLs.privacyPolicy)
        ]
    }

    // Touch handling
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let text = attributedText else { return }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        let textStorage = NSTextStorage(attributedString: text)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode

        let location = touch.location(in: self)

        // Adjust for text alignment and vertical position
        var point = location
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let xOffset = (bounds.width - textBoundingBox.width) / 2 - textBoundingBox.minX
        let yOffset = (bounds.height - textBoundingBox.height) / 2 - textBoundingBox.minY
        point.x -= xOffset
        point.y -= yOffset

        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)

        for link in links where NSLocationInRange(characterIndex, link.range) {
            linkTapHandler?(link.identifier)
            break
        }
    }
}
