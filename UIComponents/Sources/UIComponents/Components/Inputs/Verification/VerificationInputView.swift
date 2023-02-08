import UIKit

private class _BackwardListenerInputView: UITextField {
    // MARK: - Accessible properties
    let onBackward: () -> Void

    // MARK: - Initialization
    init(onBackward: @escaping () -> Void) {
        self.onBackward = onBackward
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func deleteBackward() {
         onBackward()
         super.deleteBackward()
     }
}

extension _VerificationElementInputView {
    enum State {
        case normal
        case error
    }
}

private final class _VerificationElementInputView: _BackwardListenerInputView,
                                                    UITextFieldDelegate {
    // MARK: - Private properties
    private var fieldState: State = .normal {
        didSet {
            setupStyle()
        }
    }

    // MARK: - Accessible properties
    let onForward: (String?) -> Void

    // MARK: - Initialization
    init(
        onForward: @escaping (String?) -> Void,
        onBackward: @escaping () -> Void
    ) {
        self.onForward = onForward
        super.init(onBackward: onBackward)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func canPerformAction(
        _ action: Selector,
        withSender sender: Any?
    ) -> Bool {
        return false
    }

    // MARK: - Configuration
    func apply(_ state: State) {
       fieldState = state
    }

    // MARK: - Setup
    private func setup() {
        delegate = self
        addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: UIControl.Event.editingChanged
        )

        setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.horizontal
        )
        setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
        heightAnchor ~= widthAnchor * 1.1
        textAlignment = .center
        setupStyle()
    }

    private func setupStyle() {
        switch fieldState {
        case .normal:
            backgroundColor = designEngine.colors.backgroundPrimary
            textColor = designEngine.colors.textPrimary
            font = designEngine.fonts.primary.medium(28.0)
            cornerRadius()
            shadow()
            border(
                color: .clear,
                width: 0.0
            )
            tintColor = designEngine.colors.accent
        case .error:
            backgroundColor = designEngine.colors.backgroundPrimary
            textColor = designEngine.colors.textPrimary
            font = designEngine.fonts.primary.medium(28.0)
            cornerRadius()
            shadow(color: designEngine.colors.error)
            border(
                color: designEngine.colors.error,
                width: 1.0
            )
            tintColor = designEngine.colors.error
        }
    }

    // MARK: - Delegate
    func isReplaceable(
         text: String?,
         addition: String
    ) -> Bool {
        text.map { $0.appending(addition).count < 2 } ?? false
    }

    func textField(
         _ textField: UITextField,
         shouldChangeCharactersIn range: NSRange,
         replacementString string: String
    ) -> Bool {
        let isReplaceable = isReplaceable(text: textField.text, addition: string)
        return isReplaceable
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        text = textField.text
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard !(textField.text?.isEmpty ?? true) else { return }
        onForward(textField.text)
    }
}

public final class VerificationInputStoreItem {
    public let identifier: String
    public var text: String?

    public init(identifier: String, text: String?) {
        self.identifier = identifier
        self.text = text
    }
}

public extension VerificationInputView {
    struct Model {
        public let code: [VerificationInputStoreItem]

        public init(code: [VerificationInputStoreItem]) {
            self.code = code
        }
    }

    enum State {
        case normal
        case error
    }
}

public final class VerificationInputView: UIView {
    // MARK: - Private properties
    private let containerView: UIStackView = {
        let item = UIStackView().prepareForAutoLayout()
        item.axis = .horizontal
        item.alignment = .top
        item.distribution = .fillEqually
        item.spacing = 16.0
        return item
    }()

    private var inputViews: [_VerificationElementInputView]

    // MARK: - Accessible properties
    public override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: - Actions
    public var onChange: (([VerificationInputStoreItem]) -> Void)?

    // MARK: - Initialization
    public init() {
        self.inputViews = []
        super.init(frame: CGRect.zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: Model) {
        inputViews.removeAll()
        containerView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        model.code.enumerated().forEach { digit in
            let item = _VerificationElementInputView(
                onForward: { [weak self, digit] text in
                    defer {
                        self?.onChange?(model.code)
                    }
                    model.code[safe: digit.offset]?.text = text
                    guard
                        let nextItem = self?.containerView
                            .arrangedSubviews[safe: digit.offset + 1]
                    else { return }
                    nextItem.becomeFirstResponder()
                }, onBackward: { [weak self, digit] in
                    guard
                        let previousItem = self?.containerView
                            .arrangedSubviews[safe: digit.offset - 1]
                    else { return }
                    if model.code[safe: digit.offset]?.text == nil {
                        previousItem.becomeFirstResponder()
                    } else {
                        model.code[safe: digit.offset]?.text = nil
                    }
                    self?.onChange?(model.code)
                }
            ).prepareForAutoLayout()
            item.keyboardType = .numberPad
            item.text = digit.element.text
            containerView.addArrangedSubview(item)
            inputViews.append(item)
        }
    }

    public func apply(_ state: State) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.isRemovedOnCompletion = true
        animation.fromValue = NSValue(
            cgPoint: CGPoint(x: center.x - 10, y: center.y)
        )
        animation.toValue = NSValue(
            cgPoint: CGPoint(x: center.x + 10, y: center.y)
        )

        CATransaction.begin()
        UIView.animate(withDuration: 0.1) {
            self.inputViews.forEach {
                switch state {
                case .normal:
                    $0.apply(.normal)
                case .error:
                    $0.apply(.error)
                }
            }
        }

        switch state {
        case .normal:
            break
        case .error:
            layer.add(animation, forKey: "position")
        }
        CATransaction.commit()
    }

    // MARK: - Setup
    private func setup() {
        addSubview(containerView)
        containerView.leadingAnchor ~= leadingAnchor
        containerView.topAnchor ~= topAnchor
        containerView.trailingAnchor ~= trailingAnchor
        containerView.bottomAnchor ~= bottomAnchor

        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPressWasFired(_:))
        )
        longPressGestureRecognizer.minimumPressDuration = 0.3
        addGestureRecognizer(longPressGestureRecognizer)
    }

    // MARK: - Handlers
    @objc private func longPressWasFired(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
            let senderView = sender.view,
            let superView = sender.view?.superview
        else { return }

        senderView.becomeFirstResponder()

        let saveMenuItem = UIMenuItem(
            title: "Copy",
            action: #selector(copyActionWasFired)
        )
        let deleteMenuItem = UIMenuItem(
            title: "Paste",
            action: #selector(pasteActionWasFired)
        )
        UIMenuController.shared.menuItems = [saveMenuItem, deleteMenuItem]
        UIMenuController.shared.showMenu(from: superView, rect: senderView.frame)
    }

    @objc private func copyActionWasFired() { }

    @objc private func pasteActionWasFired() { }
}
