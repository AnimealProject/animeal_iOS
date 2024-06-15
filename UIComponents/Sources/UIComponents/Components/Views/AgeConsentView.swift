//
//  AgeConsentView.swift
//
//
//  Created by Shashank Kaushik on 26/05/24.
//

import Combine
import Style
import UIKit

public final class AgeConsentView: UIStackView {
    private let checkboxImageView = UIImageView()
    private let label = UILabel()
    private var viewModel: AgeConsentViewModel? {
        didSet {
            updateUI(viewModel?.state ?? .unchecked)
        }
    }

    public var onTap: ((Bool) -> (Void))?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(_ viewModel: AgeConsentViewModel) {
        self.viewModel = viewModel
    }
}

private extension AgeConsentView {
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

public extension AgeConsentView {

    class AgeConsentViewModel: ObservableObject, AgeConsentViewModelProtocol {
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

public enum CheckBoxState {
    case checked
    case unchecked
}

public protocol AgeConsentViewModelProtocol {
    var title: String { get }
    var state: CheckBoxState { get }
}
