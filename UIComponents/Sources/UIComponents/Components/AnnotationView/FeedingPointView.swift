import UIKit
import Style

public final class FeedingPointView: UIView {
    // MARK: - Private properties
    private var model: Model?
    private let button = UIButton()
    private var circleLayer: CALayer = {
        let layer = CALayer()
        let radius: CGFloat = 87
        layer.backgroundColor = Asset.Colors.carminePink.color.withAlphaComponent(0.2).cgColor
        layer.borderColor = Asset.Colors.carminePink.color.withAlphaComponent(0.32).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = radius
        return layer
    }()

    // MARK: - Public properties
    public var tapAction: ((String) -> Void)?

    // MARK: - Initialization
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: Model) {
        self.model = model
        button.setImage(model.kind.image, for: .normal)

        if circleLayer.superlayer == nil {
            circleLayer.isHidden = true
            circleLayer.frame = CGRect(x: -57, y: -57, width: 174, height: 174)
            layer.insertSublayer(circleLayer, at: 0)
        }
    }
}

private extension FeedingPointView {
    func setup() {
        button.addTarget(self, action: #selector(handleTapAction), for: .touchUpInside)
        addSubview(button.prepareForAutoLayout())

        button.leftAnchor ~= leftAnchor
        button.rightAnchor ~= rightAnchor
        button.topAnchor ~= topAnchor
        button.bottomAnchor ~= bottomAnchor
    }

    @objc func handleTapAction() {
        circleLayer.isHidden.toggle()
        guard let identifier = model?.identifier else { return }
        tapAction?(identifier)
    }
}
