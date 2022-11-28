import Foundation

public protocol FeedingTimerProviderProtocol {
    var onCountdownTimerChanged: ((TimeInterval) -> Void)? { get set }
    var onTimerFinished: (() -> Void)? { get set }

    func start()
    func stop()
}

public final class FeedingTimerProvider: FeedingTimerProviderProtocol {
    // MARK: Private properties
    private let configuration: FeedingTimerProvider.Configuration
    private var countdownTimer: Timer?
    private var timeLeft: TimeInterval

    // MARK: Public properties
    public var onCountdownTimerChanged: ((TimeInterval) -> Void)?
    public var onTimerFinished: (() -> Void)?

    // MARK: - Initialization
    public init(configuration: FeedingTimerProvider.Configuration) {
        self.configuration = configuration
        self.timeLeft = configuration.countdownInterval
    }

    deinit {
        countdownTimer?.invalidate()
    }

    // MARK: - Public API
    public func start() {
        onCountdownTimerChanged?(configuration.countdownInterval)
        countdownTimer = Timer.scheduledTimer(
            withTimeInterval: .init(configuration.timerInterval),
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            if self.timeLeft > 0 {
                self.timeLeft -= 1
                self.onCountdownTimerChanged?(self.timeLeft)
            } else {
                self.stop()
            }
        }
    }

    public func stop() {
        countdownTimer?.invalidate()
        onTimerFinished?()
    }
}

// MARK: - Timer Configuration
public extension FeedingTimerProvider {
    struct Configuration {
        public let timerInterval: TimeInterval
        public let countdownInterval: TimeInterval

        public init(timerInterval: TimeInterval, countdownInterval: TimeInterval) {
            self.timerInterval = timerInterval
            self.countdownInterval = countdownInterval
        }

        public static var `default`: Configuration {
            return .init(timerInterval: 1, countdownInterval: 60 * 60)
        }
    }
}
