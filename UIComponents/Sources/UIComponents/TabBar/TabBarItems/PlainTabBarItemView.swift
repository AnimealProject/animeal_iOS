import UIKit

public class PlainTabBarItemView: UIView {
    // MARK: - Private properties
    private let model: TabBarItemViewModel
    private let titleLabel = UILabel()
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()

    // MARK: - Initialization
    public init(model: TabBarItemViewModel) {
        self.model = model
        super.init(frame: .zero)
        setupUI()
        fillContent()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlainTabBarItemView: TabBarItemView {
    // MARK: - Public interface
    public func setSelected(_ isSelected: Bool) {
        UIView.animate(withDuration: 0.2) {
            if isSelected {
                self.imageView.image = self.model.icon?.withTintColor(
                    self.designEngine.colors.accentTint.uiColor
                )
            } else {
                self.imageView.image = self.model.icon?.withTintColor(
                    self.designEngine.colors.textPrimary.uiColor
                )
            }
            self.titleLabel.alpha = !isSelected ? 0 : 1
        }
    }
}

private extension PlainTabBarItemView {
    // MARK: - Setup
    func setupUI() {
        addSubview(imageView.prepareForAutoLayout())
        imageView.centerXAnchor ~= centerXAnchor
        imageView.topAnchor ~= topAnchor
        imageView.heightAnchor ~= 26
        imageView.widthAnchor ~= 26

        addSubview(titleLabel.prepareForAutoLayout())
        titleLabel.leadingAnchor ~= leadingAnchor
        titleLabel.trailingAnchor ~= trailingAnchor
        titleLabel.bottomAnchor ~= bottomAnchor
        titleLabel.topAnchor ~= imageView.bottomAnchor + 3
        titleLabel.textAlignment = .center
    }

    func fillContent() {
        imageView.image = model.icon
        titleLabel.text = model.title
        titleLabel.font = designEngine.fonts.primary.semibold(10).uiFont
        titleLabel.textColor = designEngine.colors.accentTint.uiColor
    }
}
