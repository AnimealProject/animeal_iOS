// System
import UIKit

// SDK
import Style

// MARK: - Model
public extension UnderlinedSegmentedControl {
    struct Model {
        public let selectedItemIdentifier: String?
        public let items: [UnderlinedSegmentedItemView.Model]

        public init(
            selectedItemIdentifier: String?,
            items: [UnderlinedSegmentedItemView.Model]
        ) {
            self.selectedItemIdentifier = selectedItemIdentifier
            self.items = items
        }
    }
}

// MARK: - View
public class UnderlinedSegmentedControl: UIView {
    // MARK: - Constants
    private enum Constants {
        static let barHeight: CGFloat = 2.0
        static let barTopOffset: CGFloat = 6.0
    }

    // MARK: - UI properties
    let selectorView = UIView().prepareForAutoLayout()
    private(set) var segments: [UnderlinedSegmentedItemView] = []

    // MARK: - Selected index
    private(set) var selectedItemIdentifier: String?

    // MARK: - Constraints
    private var barWidthConstraint: NSLayoutConstraint?
    private var barCenterXConstraint: NSLayoutConstraint?
    
    // MARK: - Handlers
    public var onSegmentWasChanged: ((String) -> Void)?

    // MARK: - Configuration
    public func configure(_ model: Model) {
        subviews.forEach { $0.removeFromSuperview() }

        selectedItemIdentifier = model.selectedItemIdentifier

        configureSegments(with: model.items)
        configureStackView()
        configureSelectorView()

        apply(style: .default)
    }
}

private extension UnderlinedSegmentedControl {
    var selectedIndex: Int {
        segments.firstIndex { $0.identifier == selectedItemIdentifier } ?? .zero
    }

    var selectedSegment: UnderlinedSegmentedItemView {
        segments[selectedIndex]
    }

    var inactiveSegments: [UnderlinedSegmentedItemView] {
        segments.filter { $0 != selectedSegment }
    }
}

private extension UnderlinedSegmentedControl {
    func updateSegments() {
        segments.forEach {
            if $0.identifier == selectedItemIdentifier {
                $0.apply(style: .selected)
            } else {
                $0.apply(style: .normal)
            }
        }
    }

    func updateActiveIndex(_ index: Int, animated: Bool = true) {
        guard segments.indices.contains(index) else { return }

        selectedItemIdentifier = segments[safe: index]?.identifier
        updateSegments()
        updateSelectorPosition(animated: animated)
    }

    func updateSelectorPosition(animated: Bool = false) {
        barWidthConstraint?.isActive = false
        barWidthConstraint = selectorView.widthAnchor.constraint(
            equalTo: selectedSegment.widthAnchor
        )
        barWidthConstraint?.isActive = true

        barCenterXConstraint?.isActive = false
        barCenterXConstraint = selectorView.centerXAnchor.constraint(
            equalTo: selectedSegment.titleView.centerXAnchor
        )
        barCenterXConstraint?.isActive = true

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }

    @objc func segmentAction(_ sender: UITapGestureRecognizer) {
        guard
            let senderSegment = sender.view as? UnderlinedSegmentedItemView,
            let segmentIndex = segments.firstIndex(of: senderSegment)
        else { return }

        updateActiveIndex(segmentIndex)
        onSegmentWasChanged?(segments[segmentIndex].identifier)
    }
}

private extension UnderlinedSegmentedControl {
    func configureSegments(
        with items: [UnderlinedSegmentedItemView.Model]
    ) {
        segments.removeAll()

        segments = items.map {
            let itemView = UnderlinedSegmentedItemView()
            itemView.configure($0)
            return itemView
        }

        configureGesture(for: segments)
    }

    func configureStackView() {
        let stack = UIStackView(arrangedSubviews: segments)
            .prepareForAutoLayout()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually

        addSubview(stack)

        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    func configureSelectorView() {
        selectorView.cornerRadius(Constants.barHeight / 2.0)

        addSubview(selectorView)

        selectorView.topAnchor.constraint(
            equalTo: selectedSegment.titleView.lastBaselineAnchor,
            constant: Constants.barTopOffset
        ).isActive = true
        selectorView.heightAnchor.constraint(
            equalToConstant: Constants.barHeight
        ).isActive = true

        updateSelectorPosition()
    }

    func configureGesture(for segments: [UnderlinedSegmentedItemView]) {
        segments.forEach { segment in
            let tap = UITapGestureRecognizer(
                target: self,
                action: #selector(segmentAction(_:))
            )
            segment.addGestureRecognizer(tap)
        }
    }
}

public extension Style where Component: UnderlinedSegmentedControl {
    static var `default`: Style {
        return Style { component in
            let designEngine = component.designEngine
            component.backgroundColor = designEngine.colors.backgroundPrimary.uiColor
            component.selectorView.backgroundColor = designEngine.colors.accent.uiColor
            component.updateSegments()
        }
    }
}
