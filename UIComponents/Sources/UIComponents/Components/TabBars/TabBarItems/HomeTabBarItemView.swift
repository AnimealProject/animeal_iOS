import UIKit

public class HomeTabBarItemView: UIView {
    // MARK: - Private properties
    private let model: TabBarItemViewModel
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    private lazy var circleView: CircleView = {
        let view = CircleView(
            frame: CGRect(x: 0, y: 0, width: 62, height: 62)
        )
        return view
    }()

    // MARK: - Initialization
    public init(model: TabBarItemViewModel) {
        self.model = model
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension HomeTabBarItemView {
    // MARK: - Setup
    func setup() {
        backgroundColor = .clear
        heightAnchor ~= 62
        widthAnchor ~= 62

        addSubview(circleView.prepareForAutoLayout())
        circleView.bottomAnchor ~= bottomAnchor - 22
        circleView.leadingAnchor ~= leadingAnchor
        circleView.trailingAnchor ~= trailingAnchor
        circleView.heightAnchor ~= 62

        circleView.addSubview(imageView.prepareForAutoLayout())
        imageView.centerXAnchor ~= circleView.centerXAnchor
        imageView.centerYAnchor ~= circleView.centerYAnchor
        imageView.heightAnchor ~= 26
        imageView.widthAnchor ~= 26
    }
}

extension HomeTabBarItemView: TabBarItemView {
    // MARK: - Public interface
    public func setSelected(_ isSelected: Bool) {
        if isSelected {
            self.circleView.fill(self.designEngine.colors.accent.uiColor)
            self.imageView.image = self.model.icon
            circleView.addShadow(designEngine.colors.accent.uiColor)
        } else {
            self.circleView.fill(designEngine.colors.backgroundPrimary.uiColor)
            self.imageView.image = self.model.icon?.withTintColor(
                designEngine.colors.textPrimary.uiColor
            )
            circleView.addShadow(designEngine.colors.textPrimary.uiColor)
        }
    }
}
