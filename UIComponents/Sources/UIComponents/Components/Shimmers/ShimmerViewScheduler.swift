import Foundation

public protocol ShimmerViewSchedulerListener: AnyObject {
    func schedulerFired(_ scheduler: ShimmerViewScheduler)
}

public class ShimmerViewScheduler {
    private(set) var period: TimeInterval
    private(set) var isActive = false
    private var timer: DispatchSourceTimer?
    private let statusQueue = DispatchQueue(
        label: "com.epmedu.shimmer-scheduler.status-queue",
        qos: .userInteractive,
        attributes: .concurrent
    )
    private let timerQueue = DispatchQueue(
        label: "com.epmedu.shimmer-scheduler.timer-queue",
        qos: .userInteractive,
        attributes: .concurrent
    )
    private var listeners = NSHashTable<AnyObject>(
        options: [.weakMemory, .objectPointerPersonality]
    )

    public func addListener(_ listener: ShimmerViewSchedulerListener) {
        listeners.add(listener)
    }

    public func removeListener(_ listener: ShimmerViewSchedulerListener) {
        listeners.remove(listener)
    }

    public init(period: TimeInterval = 1.2) {
        self.period = period
    }

    deinit {
        timer?.cancel()
    }

    public func start() {
        statusQueue.async(flags: .barrier) {
            guard !self.isActive else {
                return
            }
            self.isActive = true
            self.scheduleTimer()
        }
    }

    public func stop() {
        statusQueue.async(flags: .barrier) {
            self.isActive = false
            self.timer?.cancel()
            self.timer = nil
        }
    }

    private func handleTick() {
        DispatchQueue.main.async {
            guard let listeners = self.listeners.copy() as? NSHashTable<AnyObject> else {
                return
            }
            for listener in listeners.objectEnumerator() {
                if let listener = listener as? ShimmerViewSchedulerListener {
                    listener.schedulerFired(self)
                }
            }
        }
    }

    private func scheduleTimer() {
        timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer?.schedule(
            deadline: .now(),
            repeating: .milliseconds(Int(period * 1000)),
            leeway: .milliseconds(100)
        )
        timer?.setEventHandler { [weak self] in
            self?.handleTick()
        }
        timer?.resume()
    }
}

extension ShimmerViewScheduler: Hashable {
    public static func == (
        lhs: ShimmerViewScheduler,
        rhs: ShimmerViewScheduler
    ) -> Bool {
        lhs.isActive == rhs.isActive
        && lhs.period == rhs.period
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(isActive)
        hasher.combine(period)
    }
}
