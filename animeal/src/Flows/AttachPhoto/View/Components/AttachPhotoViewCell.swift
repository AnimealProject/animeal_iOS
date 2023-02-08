// System
import UIKit
// SDK
import UIComponents
import Style

protocol AttachPhotoViewCellContainable where Self: UICollectionViewCell {
    static var reuseIdentifier: String { get }
}

extension AttachPhotoViewCell {
    struct Model {
        let image: UIImage
    }
}

final class AttachPhotoViewCell: UICollectionViewCell, AttachPhotoViewCellContainable {
    // MARK: - Constants
    private enum Constants {
        static let imageSideSize: CGFloat = 70.0
        static let imageCornerRadius: CGFloat = 12.0
        static let offset: CGFloat = 6.0
        static let closeIconSideSize: CGFloat = 9.0
        static let circleSideSize: CGFloat = 22.0
    }
    
    // MARK: - Reuse identifier
    static var reuseIdentifier: String { String(describing: self) }
    
    // MARK: - Public properties
    public var onTapCloseAction: (() -> Void)?
    
    // MARK: - UI properties
    private lazy var placeImageView: UIImageView = {
        let imageView = UIImageView().prepareForAutoLayout()
        imageView.contentMode = .scaleAspectFill
        imageView.widthAnchor ~= Constants.imageSideSize
        imageView.heightAnchor ~= Constants.imageSideSize
        imageView.clipsToBounds = true
        imageView.cornerRadius(Constants.imageCornerRadius)
        return imageView
    }()
    
    private let circleView: UIView = {
        let view = UIView().prepareForAutoLayout()
        view.widthAnchor ~= Constants.circleSideSize
        view.heightAnchor ~= Constants.circleSideSize
        view.clipsToBounds = true
        view.cornerRadius(Constants.circleSideSize/2)
        view.backgroundColor = .systemGray
        view.layer.borderWidth = 2
        view.layer.borderColor = view.designEngine.colors.backgroundPrimary.cgColor
        return view
    }()
    
    private lazy var circleViewTapRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(circleViewWasTapped)
    )
    
    private lazy var closeImageView: UIImageView = {
        let imageView = UIImageView().prepareForAutoLayout()
        imageView.contentMode = .scaleToFill
        imageView.image = Asset.Images.crosIcon.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.widthAnchor ~= Constants.closeIconSideSize
        imageView.heightAnchor ~= Constants.closeIconSideSize
        return imageView
    }()
    
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
        placeImageView.image = model.image
    }
    
    // MARK: - Setup
    private func setup() {
        contentView.backgroundColor = designEngine.colors.backgroundPrimary
        contentView.addSubview(placeImageView)
        placeImageView.topAnchor ~= contentView.topAnchor + Constants.offset
        placeImageView.centerYAnchor ~= contentView.centerYAnchor
        placeImageView.centerXAnchor ~= contentView.centerXAnchor
        
        contentView.addSubview(circleView)
        circleView.topAnchor ~= contentView.topAnchor
        circleView.trailingAnchor ~= contentView.trailingAnchor
        circleView.addGestureRecognizer(circleViewTapRecognizer)
        
        contentView.addSubview(closeImageView)
        closeImageView.centerXAnchor ~= circleView.centerXAnchor
        closeImageView.centerYAnchor ~= circleView.centerYAnchor
    }
    
    // MARK: - Handlers
    @objc private func circleViewWasTapped() {
        onTapCloseAction?()
    }
}
