import UIKit
import MapKit
import Style

public final class FeedingControlView: UIView {
    // MARK: Private properties
    private var timerProvider: FeedingTimerProviderProtocol
    private let timeLeftLabel = UILabel()
    private let distanceLabel = UILabel()
    private var cancelButton: UIButton?
    private let timeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()
    private let distanceFormatter: MKDistanceFormatter = {
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.units = .metric
        distanceFormatter.unitStyle = .abbreviated
        return distanceFormatter
    }()

    // MARK: Public properties
    public var onCloseHandler: (() -> Void)?
    public var onTimerFinishHandler: (() -> Void)?

    // MARK: - Initialization
    public init(
        timerProvider: FeedingTimerProviderProtocol = FeedingTimerProvider(configuration: .default)
    ) {
        self.timerProvider = timerProvider
        super.init(frame: .zero)
        setupTimerProvider()
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func updateDistance(_ distance: Double) {
        let prettyString = distanceFormatter.string(fromDistance: distance)
        distanceLabel.text = prettyString
    }

    public func stopTimer() {
        timerProvider.stop()
    }

    public func startTimer() {
        timerProvider.start()
    }

    public func setTimerProvider(_ provider: FeedingTimerProviderProtocol) {
        timerProvider.stop()
        timerProvider = provider
        setupTimerProvider()
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 40), height: 56)
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        cancelButton?.apply(style: .buttonStyle)
    }
}

// MARK: - Setup
private extension FeedingControlView {
    func setupViews() {
        backgroundColor = designEngine.colors.backgroundPrimary
        layer.cornerRadius = 10

        timeLeftLabel.font = designEngine.fonts.primary.bold(20)
        distanceLabel.font = designEngine.fonts.primary.regular(16)


        addSubview(timeLeftLabel.prepareForAutoLayout())
        timeLeftLabel.leadingAnchor ~= leadingAnchor + 18
        timeLeftLabel.centerYAnchor ~= centerYAnchor

        let dotView = UIView()
        dotView.backgroundColor = designEngine.colors.textSecondary
        dotView.layer.cornerRadius = 3
        addSubview(dotView.prepareForAutoLayout())
        dotView.leadingAnchor ~= timeLeftLabel.trailingAnchor + 10
        dotView.centerYAnchor ~= centerYAnchor
        dotView.widthAnchor ~= 6
        dotView.heightAnchor ~= 6

        addSubview(distanceLabel.prepareForAutoLayout())
        distanceLabel.leadingAnchor ~= dotView.trailingAnchor + 12
        distanceLabel.centerYAnchor ~= centerYAnchor

        let action = UIAction { [weak self] _ in
            self?.onCloseHandler?()
        }

        let button = UIButton(primaryAction: action)
        cancelButton = button
        cancelButton?.apply(style: .buttonStyle)

        addSubview(button.prepareForAutoLayout())
        button.trailingAnchor ~= trailingAnchor
        button.centerYAnchor ~= centerYAnchor
        button.widthAnchor ~= 44
        button.heightAnchor ~= 44
    }

    func setupTimerProvider() {
        timerProvider.onCountdownTimerChanged = { [weak self] timeInterval in
            let timeLeft = self?.timeIntervalFormatter.string(from: timeInterval) ?? "0"
            self?.timeLeftLabel.text = "\(timeLeft) min"
        }
        timerProvider.onTimerFinished = { [weak self] in
            self?.onTimerFinishHandler?()
        }
    }
}

private extension Style where Component == UIButton {
    static var buttonStyle: Style<UIButton> {
        .init { button in
            let tintColor = Asset.Colors.lightBackgroundButtonTint.color
            let image = UIImage(systemName: "xmark")?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
            button.setImage(image, for: .normal)
        }
    }
}
