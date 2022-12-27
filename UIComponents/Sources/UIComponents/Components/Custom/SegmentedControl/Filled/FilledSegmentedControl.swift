import UIKit
import Common

public final class FilledSegmentedControl: UISegmentedControl {
    // MARK: - Public properties
    public var onTap: ((Int) -> Void)?

    // MARK: - Private properties
    private var model: Model?

    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override public init(items: [Any]?) {
        super.init(items: items)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: FilledSegmentedControl.Model) {
        self.model = model

        removeAllSegments()
        for (index, item) in model.items.enumerated() {
            insertSegment(withTitle: item.title, at: index, animated: false)
            if item.isSelected {
                selectedSegmentIndex = index
            }
        }
        if selectedSegmentIndex == UISegmentedControl.noSegment {
            selectedSegmentIndex = 0
        }

        addTarget(self, action: #selector(segmentedControlTapHandler(_:)), for: .valueChanged)
    }
}

// MARK: - Private API
private extension FilledSegmentedControl {
    @objc func segmentedControlTapHandler(_ segmentedControl: UISegmentedControl) {
        onTap?(segmentedControl.selectedSegmentIndex)
    }

    func setup() {
        backgroundColor = designEngine.colors.backgroundPrimary.uiColor
        selectedSegmentTintColor = designEngine.colors.accent.uiColor
        setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: designEngine.colors.textPrimary.uiColor],
            for: .selected
        )
    }
}
