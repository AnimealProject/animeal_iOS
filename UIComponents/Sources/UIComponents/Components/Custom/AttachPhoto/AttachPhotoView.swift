import UIKit
import Style

public final class AttachPhotoView: UIView {
    // MARK: - Constants
    public enum Constants {
        static let spacing: CGFloat = 16.0
        static let iconSideSize: CGFloat = 60.0
        static let cornerRadius: CGFloat = 16
        static let lineColor: UIColor = .systemGray4
    }
    
    // MARK: - Public properties
    public var onTapFinishButton: (() -> Void)?
    public var onTapAttachPhoto: (() -> Void)?
    
    // MARK: - Private properties
    private var topLine: UIView = {
        let view = UIView().prepareForAutoLayout()
        view.heightAnchor ~= 2
        view.widthAnchor ~= 18
        view.layer.cornerRadius = 1
        view.clipsToBounds = true
        view.backgroundColor = Constants.lineColor
        return view
    }()
    
    private lazy var placeImageView: UIImageView = {
        let imageView = UIImageView().prepareForAutoLayout()
        imageView.contentMode = .scaleToFill
        imageView.widthAnchor ~= Constants.iconSideSize
        imageView.heightAnchor ~= Constants.iconSideSize
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var placeTitleView: UILabel = {
        let item = UILabel().prepareForAutoLayout()
        item.font = designEngine.fonts.primary.medium(16.0).uiFont
        item.textColor = designEngine.colors.textPrimary.uiColor
        item.numberOfLines = 0
        item.textAlignment = .left
        return item
    }()
    
    private let placeInfoStackView: UIStackView = {
        let item = UIStackView().prepareForAutoLayout()
        item.axis = .horizontal
        item.spacing = Constants.spacing
        return item
    }()
    
    private let seperatorLine: UIView = {
        let view = UIView().prepareForAutoLayout()
        view.heightAnchor ~= 1
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private lazy var hintTextView: UILabel = {
        let item = UILabel().prepareForAutoLayout()
        item.font = designEngine.fonts.primary.regular(12.0).uiFont
        item.textColor = designEngine.colors.textPrimary.uiColor
        item.numberOfLines = 0
        item.textAlignment = .left
        return item
    }()
    
    private lazy var attachButton: UIButton = {
        let action = UIAction { [weak self] _ in
            self?.onTapAttachPhoto?()
        }
        let button = UIButton(primaryAction: action).prepareForAutoLayout()
        button.setImage(Asset.Images.attachPhoto.image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.widthAnchor ~= 70
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: .zero, bottom: 6, right: .zero)
        return button
    }()
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let item = UICollectionView(frame: .zero, collectionViewLayout: layout)
            .prepareForAutoLayout()
        return item
    }()
    
    private let attachStackView: UIStackView = {
        let item = UIStackView().prepareForAutoLayout()
        item.axis = .horizontal
        item.spacing = Constants.spacing
        item.heightAnchor ~= 76
        return item
    }()
    
    private let contentStackView: UIStackView = {
        let item = UIStackView().prepareForAutoLayout()
        item.axis = .vertical
        item.spacing = Constants.spacing
        item.distribution = .equalSpacing
        return item
    }()
    
    private var finishButton = ButtonViewFactory().makeDisabledButton()
    
    // MARK: - Initialization
    public init(frame: CGRect, collectionView: UICollectionView) {
        super.init(frame: frame)
        self.collectionView = collectionView
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    public func configure(_ model: Model) {
        placeImageView.image = model.placeImage
        placeTitleView.text = model.placeTitle
        hintTextView.text = model.hintTitle
        
        finishButton.configure(
            ButtonView.Model(
                identifier: UUID().uuidString,
                viewType: ButtonView.self,
                title: model.buttonTitle
            )
        )
        finishButton.onTap = {[weak self]_ in
            self?.onTapFinishButton?()
        }
    }
    
    public func configureFinishButtonStyle(_ state: Bool) {
        finishButton.apply(style: state ? .active : .inActive)
    }
}

private extension AttachPhotoView {
    // MARK: - Setup
    func setup() {
        addSubview(topLine)
        topLine.topAnchor ~= topAnchor + 12
        topLine.centerXAnchor ~= centerXAnchor
        
        addSubview(placeInfoStackView)
        placeInfoStackView.topAnchor ~= topLine.bottomAnchor + Constants.spacing
        placeInfoStackView.leftAnchor ~= leftAnchor
        placeInfoStackView.rightAnchor ~= rightAnchor
        placeInfoStackView.addArrangedSubview(placeImageView)
        placeInfoStackView.addArrangedSubview(placeTitleView)
        
        addSubview(seperatorLine)
        seperatorLine.topAnchor ~= placeInfoStackView.bottomAnchor + 20
        seperatorLine.leftAnchor ~= leftAnchor
        seperatorLine.rightAnchor ~= rightAnchor
        
        addSubview(hintTextView)
        hintTextView.topAnchor ~= seperatorLine.bottomAnchor + 10
        hintTextView.leftAnchor ~= leftAnchor
        hintTextView.rightAnchor ~= rightAnchor
        
        addSubview(contentStackView)
        contentStackView.topAnchor ~= hintTextView.bottomAnchor + 10
        contentStackView.leftAnchor ~= leftAnchor
        contentStackView.rightAnchor ~= rightAnchor
        contentStackView.bottomAnchor ~= bottomAnchor - 40
        
        attachStackView.addArrangedSubview(attachButton)
        attachStackView.addArrangedSubview(collectionView)
        
        contentStackView.addArrangedSubview(attachStackView)
        contentStackView.addArrangedSubview(finishButton)
    }
}

extension Style where Component: ButtonView {
    // MARK: - Styles
    static var active: Style {
        Style { component in
            let designEngine = component.designEngine
            component.contentView.isUserInteractionEnabled = true
            component.contentView.backgroundColor = designEngine.colors.accent.uiColor
            component.contentView.setTitleColor(
                designEngine.colors.alwaysLight.uiColor,
                for: UIControl.State.normal
            )
            component.contentView.setTitleColor(
                designEngine.colors.textSecondary.uiColor,
                for: UIControl.State.highlighted
            )
        }
    }
    
    static var inActive: Style {
        Style { component in
            let designEngine = component.designEngine
            component.contentView.isUserInteractionEnabled = false
            component.contentView.backgroundColor = designEngine.colors.disabled.uiColor
            component.contentView.setTitleColor(
                designEngine.colors.alwaysLight.uiColor,
                for: UIControl.State.normal
            )
        }
    }
}
