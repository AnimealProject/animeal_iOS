import UIKit

import UIComponents
import Style

protocol PhoneCodesViewCellContainable where Self: UICollectionViewCell {
    static var reuseIdentifier: String { get }
}

extension PhoneCodesViewCommonCell {
    struct Model {
        let identifier: String
        let icon: UIImage?
        let title: String
        let isSelected: Bool
    }
}

final class PhoneCodesViewCommonCell: UICollectionViewCell, PhoneCodesViewCellContainable {
    // MARK: - Constants
    private enum Constants {
        static let imageSideSize: CGFloat = 26.0
        static let offset: CGFloat = 16.0
    }

    // MARK: - Reuse identifier
    static var reuseIdentifier: String { String(describing: self) }

    // MARK: - UI properties
    let iconView = UIImageView().prepareForAutoLayout()
    let titleView = UILabel().prepareForAutoLayout()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    func configure(_ model: Model) {
        iconView.image = model.icon
        titleView.text = model.title

        if model.isSelected {
            apply(style: .selected)
        } else {
            apply(style: .default)
        }
    }

    // MARK: - Setup
    private func setup() {
        contentView.addSubview(iconView)
        iconView.leadingAnchor ~= contentView.leadingAnchor + Constants.offset
        iconView.topAnchor ~= contentView.topAnchor + Constants.offset
        iconView.centerYAnchor ~= contentView.centerYAnchor
        iconView.widthAnchor ~= Constants.imageSideSize
        iconView.heightAnchor ~= Constants.imageSideSize

        contentView.addSubview(titleView)
        titleView.leadingAnchor ~= iconView.trailingAnchor + Constants.offset
        titleView.centerYAnchor ~= iconView.centerYAnchor
        titleView.trailingAnchor ~= contentView.trailingAnchor - Constants.offset
    }
}

// MARK: - Styles
private extension Style where Component == PhoneCodesViewCommonCell {
    // MARK: - Constants
    enum Constants {
        static let numberOfLines = 1
        static let fontSize: CGFloat = 20.0
        static let cornerRadius: CGFloat = 12.0
    }

    static var `default`: Style<PhoneCodesViewCommonCell> {
        Style { view in
            let designEngine = view.designEngine

            view.clipsToBounds = true
            view.cornerRadius(Constants.cornerRadius)
            view.contentView.backgroundColor = designEngine.colors.backgroundPrimary.uiColor

            view.titleView.numberOfLines = Constants.numberOfLines
            view.titleView.textColor = designEngine.colors.textPrimary.uiColor
            view.titleView.font = designEngine.fonts.primary.medium(Constants.fontSize).uiFont
        }
    }

    static var selected: Style<PhoneCodesViewCommonCell> {
        Style { view in
            let designEngine = view.designEngine

            view.clipsToBounds = true
            view.cornerRadius(Constants.cornerRadius)
            view.contentView.backgroundColor = designEngine.colors.backgroundSecondary.uiColor

            view.titleView.numberOfLines = Constants.numberOfLines
            view.titleView.textColor = designEngine.colors.textPrimary.uiColor
            view.titleView.font = designEngine.fonts.primary.medium(Constants.fontSize).uiFont
        }
    }
}