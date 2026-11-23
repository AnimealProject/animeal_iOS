//
//  TagSelectorView.swift
//  UIComponents
//
//  Created by Sona Hunanyan on 13.10.26.
//

import UIKit

public final class TagSelectorView: UIView {

    public struct Item {
        public let title: String
        public let isSelected: Bool
        public  init(title: String, isSelected: Bool = false) {
            self.title = title
            self.isSelected = isSelected
        }
    }

    public struct Model {
        public let items: [Item]
        public init(items: [Item]) {
            self.items = items
        }
    }

    public var onTap: ((Int) -> Void)?
    private var model: Model?
    private var buttons: [PillButtonView] = []
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(_ model: TagSelectorView.Model) {
            self.model = model

            buttons.forEach { $0.removeFromSuperview() }
            buttons.removeAll()

            for (index, item) in model.items.enumerated() {
                let button = createTagButton(title: item.title, isSelected: item.isSelected, tag: index)
                buttons.append(button)
                stackView.addArrangedSubview(button)
            }
        }

    func setup() {
            addSubview(scrollView)
            scrollView.addSubview(stackView)

            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

                stackView.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(
                    equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                    constant: -16
                ),
                stackView.bottomAnchor.constraint(equalTo: scrollView.frameLayoutGuide.bottomAnchor)
            ])
        }

    private func createTagButton(title: String, isSelected: Bool, tag: Int) -> PillButtonView {
        let button = ButtonViewFactory().makePillButton()
        button.configure(
            .init(
                identifier: "\(tag)",
                viewType: PillButtonView.self,
                title: title
            )
        )
        button.setSelected(isSelected)
        button.onTap = { [weak self] identifier in
            self?.handleTagTap(identifier)
        }
        return button
    }

    private func handleTagTap(_ identifier: String) {
        guard let index = Int(identifier) else { return }
        for (buttonIndex, button) in buttons.enumerated() {
            button.setSelected(buttonIndex == index)
        }
        onTap?(index)
    }
}
