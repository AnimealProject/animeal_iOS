import UIKit
import Common

public final class SegmentedControl: UISegmentedControl {
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
    public func configure(_ model: SegmentedControl.Model) {
        self.model = model

        removeAllSegments()
        for (index, item) in model.items.enumerated() {
            insertSegment(withTitle: item.title, at: index, animated: false)
        }
        selectedSegmentIndex = 0
        addTarget(self, action: #selector(segmentedControlTapHandler(_:)), for: .valueChanged)
    }
}

// MARK: - Private API
private extension SegmentedControl {
    @objc func segmentedControlTapHandler(_ segmentedControl: UISegmentedControl) {
        model?.items[safe: segmentedControl.selectedSegmentIndex]?.action?(
            segmentedControl.selectedSegmentIndex
        )
    }

    func setup() {
        backgroundColor = designEngine.colors.primary.uiColor
        selectedSegmentTintColor = designEngine.colors.accentTint.uiColor
        setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: designEngine.colors.primary.uiColor],
            for: .selected
        )
    }
}
