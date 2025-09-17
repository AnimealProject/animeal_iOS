//
//  LegalAcknowledgeView.swift
//  UIComponents
//
//  Created by Sebastián Fernández on 9/10/25.
//

import Combine
import Style
import UIKit

public final class LegalAcknowledgeView: UIStackView {
    private let checkboxImageView = UIImageView()
    private let label = UILabel()
    private var viewModel: LegalAcknowledgeViewModel? {
        didSet {
            updateUI(viewModel?.state ?? .unchecked)
        }
    }

    public var onTap: ((Bool) -> Void)?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(_ viewModel: LegalAcknowledgeViewModel) {
        self.viewModel = viewModel
    }
}

private extension LegalAcknowledgeView {
    // MARK: - Setup
    func setup() {
        axis = .horizontal
        spacing = 8.0
        distribution = .fill
        alignment = .leading
        translatesAutoresizingMaskIntoConstraints = false

        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = designEngine.fonts.primary.semibold(14.0)
        checkboxImageView.contentMode = .scaleAspectFit

        addArrangedSubview(checkboxImageView)
        addArrangedSubview(label)

        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        addGestureRecognizer(tapGesture)
    }

    @objc func handleTapGesture() {
        viewModel?.toggleState()
        onTap?(viewModel?.state == .checked)
    }

    private func updateUI(_ newState: CheckBoxState) {
        label.text = viewModel?.title
        switch newState {
        case .checked:
            checkboxImageView.image = Asset.Images.blueCheckedIcon.image
            label.textColor = designEngine.colors.textPrimary
        case .unchecked:
            checkboxImageView.image = Asset.Images.blueUncheckedIcon.image
            label.textColor = designEngine.colors.textPrimary
        }
    }
}

public extension LegalAcknowledgeView {

    class LegalAcknowledgeViewModel: ObservableObject, LegalAcknowledgeViewModelProtocol {
        public var title: String
        @Published public var state: CheckBoxState

        var cancellables = Set<AnyCancellable>()

        public init(state: CheckBoxState, title: String) {
            self.state = state
            self.title = title
        }

        func toggleState() {
            switch state {
            case .checked:
                state = .unchecked
            case .unchecked:
                state = .checked
            }
        }
    }
}

public protocol LegalAcknowledgeViewModelProtocol {
    var title: String { get }
    var state: CheckBoxState { get }
}
