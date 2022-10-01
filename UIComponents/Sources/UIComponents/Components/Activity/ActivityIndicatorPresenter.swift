import UIKit

public extension ActivityIndicatorPresenter {
    struct Model {
        public let size: CGSize
        public let message: String?
        public let messageFont: UIFont
        public let messageSpacing: CGFloat
        public let type: ActivityIndicatorType
        public let color: UIColor
        public let textColor: UIColor
        public let padding: CGFloat
        public let backgroundColor: UIColor
        public let displayTimeThreshold: Int
        public let minimumDisplayTime: Int

        public init(
            size: CGSize,
            message: String?,
            messageFont: UIFont,
            messageSpacing: CGFloat,
            type: ActivityIndicatorType,
            color: UIColor,
            textColor: UIColor,
            padding: CGFloat,
            backgroundColor: UIColor,
            displayTimeThreshold: Int = 0,
            minimumDisplayTime: Int = 0
        ) {
            self.size = size
            self.message = message
            self.messageFont = messageFont
            self.messageSpacing = messageSpacing
            self.type = type
            self.color = color
            self.textColor = textColor
            self.padding = padding
            self.backgroundColor = backgroundColor
            self.displayTimeThreshold = displayTimeThreshold
            self.minimumDisplayTime = minimumDisplayTime
        }
    }
}

public final class ActivityIndicatorPresenter {
    // MARK: - UI properties
    private lazy var window: UIWindow? = {
        guard let scene = UIApplication.shared.windows.first?.windowScene
        else { return nil }
        let window = UIWindow(windowScene: scene)
        return window
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()

        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // MARK: - State
    var state: State = .stopped
    var data: Model?
    let waitingToStartGroup = DispatchGroup()

    // MARK: - Public properties
    public var isAnimating: Bool { return state == .animating || state == .waitingToStop }

    // MARK: - Initialization
    public init() { }

    // MARK: - Public interface
    public final func startAnimating(
        _ data: Model = .`default`(),
        _ fadeInAnimation: FadeInAnimation? = ActivityIndicatorView.fadeInAnimation
    ) {
        self.data = data
        state.startAnimating(presenter: self, fadeInAnimation)
    }

    public final func stopAnimating(
        _ fadeOutAnimation: FadeOutAnimation? = ActivityIndicatorView.fadeOutAnimation
    ) {
        state.stopAnimating(presenter: self, fadeOutAnimation)
    }

    public final func setMessage(_ message: String?) {
        waitingToStartGroup.notify(queue: DispatchQueue.main) {
            self.messageLabel.text = message
        }
    }

    // MARK: - Helpers
    func show(with activityData: Model, _ fadeInAnimation: FadeInAnimation?) {
        let containerView = UIView(frame: UIScreen.main.bounds).prepareForAutoLayout()

        containerView.backgroundColor = activityData.backgroundColor
        fadeInAnimation?(containerView)

        let activityIndicatorView = ActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: activityData.size.width, height: activityData.size.height),
            type: activityData.type,
            color: activityData.color,
            padding: activityData.padding
        ).prepareForAutoLayout()
        activityIndicatorView.startAnimating()

        do {
            containerView.addSubview(activityIndicatorView)
            activityIndicatorView.centerXAnchor ~= containerView.centerXAnchor
            activityIndicatorView.centerYAnchor ~= containerView.centerYAnchor
        }

        messageLabel.font = activityData.messageFont
        messageLabel.textColor = activityData.textColor
        messageLabel.text = activityData.message

        do {
            containerView.addSubview(messageLabel)
            messageLabel.leadingAnchor ~= containerView.leadingAnchor + 8.0
            messageLabel.trailingAnchor ~= containerView.trailingAnchor - 8.0
            messageLabel.topAnchor ~= activityIndicatorView.bottomAnchor + activityData.messageSpacing
        }

        guard let window = window else { return }

        do {
            window.addSubview(containerView)
            containerView.leadingAnchor ~= window.leadingAnchor
            containerView.topAnchor ~= window.topAnchor
            containerView.trailingAnchor ~= window.trailingAnchor
            containerView.bottomAnchor ~= window.bottomAnchor
        }

        window.makeKeyAndVisible()
    }

    func hide(_ fadeOutAnimation: FadeOutAnimation?) {
        guard let window else { return }
        for item in window.subviews {
            if let fadeOutAnimation = fadeOutAnimation {
                fadeOutAnimation(item) {
                    item.removeFromSuperview()
                }
            } else {
                item.removeFromSuperview()
            }
        }

        window.resignKey()
        window.isHidden = true
    }
}

public extension ActivityIndicatorPresenter.Model {
    static func `default`(caption: String? = nil) -> Self {
        let designEngine = UIView().designEngine
        return ActivityIndicatorPresenter.Model(
            size: CGSize(width: 80.0, height: 80.0),
            message: caption,
            messageFont: designEngine.fonts.primary.semibold(16.0).uiFont
            ?? UIFont.systemFont(ofSize: 16.0, weight: .semibold),
            messageSpacing: 16.0,
            type: .circleStrokeSpin,
            color: designEngine.colors.alwaysLight.uiColor,
            textColor: designEngine.colors.alwaysLight.uiColor,
            padding: 16.0,
            backgroundColor: designEngine.colors.alwaysDark.uiColor.withAlphaComponent(0.5)
        )
    }
}

extension ActivityIndicatorPresenter {
    enum State: ActivityIndicatorPresenterState {
        case waitingToStart
        case animating
        case waitingToStop
        case stopped

        var performer: ActivityIndicatorPresenterState {
            switch self {
            case .waitingToStart: return ActivityIndicatorPresenterStateWaitingToStart()
            case .animating: return ActivityIndicatorPresenterStateAnimating()
            case .waitingToStop: return ActivityIndicatorPresenterStateWaitingToStop()
            case .stopped: return ActivityIndicatorPresenterStateStopped()
            }
        }

        func startAnimating(
            presenter: ActivityIndicatorPresenter,
            _ fadeInAnimation: FadeInAnimation?
        ) {
            performer.startAnimating(presenter: presenter, fadeInAnimation)
        }

        func stopAnimating(
            presenter: ActivityIndicatorPresenter,
            _ fadeOutAnimation: FadeOutAnimation?
        ) {
            performer.stopAnimating(presenter: presenter, fadeOutAnimation)
        }
    }
}

protocol ActivityIndicatorPresenterState {
    func startAnimating(presenter: ActivityIndicatorPresenter, _ fadeInAnimation: FadeInAnimation?)
    func stopAnimating(presenter: ActivityIndicatorPresenter, _ fadeOutAnimation: FadeOutAnimation?)
}

private struct ActivityIndicatorPresenterStateWaitingToStart: ActivityIndicatorPresenterState {
    func startAnimating(
        presenter: ActivityIndicatorPresenter,
        _ fadeInAnimation: FadeInAnimation?
    ) {
        guard let activityData = presenter.data else { return }

        presenter.show(with: activityData, fadeInAnimation)
        presenter.state = .animating
        presenter.waitingToStartGroup.leave()
    }

    func stopAnimating(
        presenter: ActivityIndicatorPresenter,
        _ fadeOutAnimation: FadeOutAnimation?
    ) {
        presenter.state = .stopped
        presenter.waitingToStartGroup.leave()
    }
}

private struct ActivityIndicatorPresenterStateAnimating: ActivityIndicatorPresenterState {
    func startAnimating(
        presenter: ActivityIndicatorPresenter,
        _ fadeInAnimation: FadeInAnimation?
    ) { }

    func stopAnimating(
        presenter: ActivityIndicatorPresenter,
        _ fadeOutAnimation: FadeOutAnimation?
    ) {
        guard let activityData = presenter.data else { return }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + .milliseconds(activityData.minimumDisplayTime)
        ) {
            guard presenter.state == .waitingToStop else { return }

            presenter.stopAnimating(fadeOutAnimation)
        }
        presenter.state = .waitingToStop
    }
}

private struct ActivityIndicatorPresenterStateWaitingToStop: ActivityIndicatorPresenterState {
    func startAnimating(
        presenter: ActivityIndicatorPresenter,
        _ fadeInAnimation: FadeInAnimation?
    ) {
        presenter.stopAnimating(nil)

        guard let activityData = presenter.data else { return }
        presenter.startAnimating(activityData, fadeInAnimation)
    }

    func stopAnimating(
        presenter: ActivityIndicatorPresenter,
        _ fadeOutAnimation: FadeOutAnimation?
    ) {
        presenter.hide(fadeOutAnimation)
        presenter.state = .stopped
    }
}

private struct ActivityIndicatorPresenterStateStopped: ActivityIndicatorPresenterState {
    func startAnimating(
        presenter: ActivityIndicatorPresenter,
        _ fadeInAnimation: FadeInAnimation?
    ) {
        guard let activityData = presenter.data else { return }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + .milliseconds(activityData.displayTimeThreshold)
        ) {
            guard presenter.state == .waitingToStart else { return }

            presenter.startAnimating(activityData, fadeInAnimation)
        }
        presenter.state = .waitingToStart
        presenter.waitingToStartGroup.enter()
    }

    func stopAnimating(presenter: ActivityIndicatorPresenter, _ fadeOutAnimation: FadeOutAnimation?) { }
}
