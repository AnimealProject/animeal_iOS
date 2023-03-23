import UIKit

open class TextInputDefaultSmallDecorator<ContentView: TextFieldContainerView>: UIView, TextInputDecoratable {
    // MARK: - Model
    public struct Model {
        public let identifier: String
        public let state: TextInputView.State
        public let content: ContentView.Model

        public init(
            identifier: String,
            state: TextInputView.State,
            content: ContentView.Model
        ) {
            self.identifier = identifier
            self.state = state
            self.content = content
        }
    }

    // MARK: - UI properties
    private(set) var contentView: ContentView
    var textView: TextFieldContainable { contentView.textView }

    // MARK: - Handlers
    public var shouldBeginEditing: ((TextFieldContainable) -> Bool)? {
        get { textView.shouldBeginEditing }
        set { textView.shouldBeginEditing = newValue }
    }

    public var didBeginEditing: ((TextFieldContainable) -> Void)? {
        get { textView.didBeginEditing }
        set { textView.didBeginEditing = newValue }
    }

    public var shouldEndEditing: ((TextFieldContainable) -> Bool)? {
        get { textView.shouldEndEditing }
        set { textView.shouldEndEditing = newValue }
    }

    public var didEndEditing: ((TextFieldContainable) -> Void)? {
        get { textView.didEndEditing }
        set { textView.didEndEditing = newValue }
    }

    public var shouldChangeCharacters: ((TextFieldContainable, NSRange, String) -> Bool)? {
        get { textView.shouldChangeCharacters }
        set { textView.shouldChangeCharacters = newValue }
    }

    public var didChange: ((TextFieldContainable) -> Void)? {
        get { textView.didChange }
        set { textView.didChange = newValue }
    }

    public var shouldClear: ((TextFieldContainable) -> Bool)? {
        get { textView.shouldClear }
        set { textView.shouldClear = newValue }
    }

    public var shouldReturn: ((TextFieldContainable) -> Bool)? {
        get { textView.shouldReturn }
        set { textView.shouldReturn = newValue }
    }

    // MARK: - Identifiable
    public private(set) var identifier: String = UUID().uuidString

    // MARK: - Initialization
    public init(contentView: ContentView) {
        self.contentView = contentView.prepareForAutoLayout()
        super.init(frame: CGRect.zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    open func configure(_ model: Model) {
        identifier = model.identifier
        contentView.configure(model.content)
        configureStyle(model.state)
    }

    open func configureStyle(_ textFieldState: TextInputView.State) {
        contentView.backgroundColor = designEngine.colors.backgroundSecondary
        switch textFieldState {
        case .normal:
            textView.font = designEngine.fonts.primary.semibold(16.0)
            textView.textColor = designEngine.colors.textPrimary
            contentView.border(width: 0.0)
        case .error:
            textView.font = designEngine.fonts.primary.semibold(16.0)
            textView.textColor = designEngine.colors.textPrimary
            contentView.border(color: designEngine.colors.error, width: 1.0)
        }
    }

    // MARK: - Setup
    private func setup() {
        addSubview(contentView)
        contentView.leadingAnchor ~= leadingAnchor
        contentView.topAnchor ~= topAnchor
        contentView.trailingAnchor ~= trailingAnchor
        contentView.bottomAnchor ~= bottomAnchor
        contentView.heightAnchor ~= 40.0

        configureStyle(.normal)
    }
}
