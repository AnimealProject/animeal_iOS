import Foundation

open class AsyncOperation: Operation {
    // MARK: - State
    @objc private enum State: Int {
        case ready
        case executing
        case finished
    }

    // MARK: - Private properties
    private let stateQueue = DispatchQueue(
        label: "ru.apptimzim.ARKEducation.async-stateQueue",
        attributes: .concurrent
    )

    private var stateStore: State = .ready

    @objc private dynamic var state: State {
        get {
            stateQueue.sync {
                stateStore
            }
        }
        set {
            stateQueue.async(flags: .barrier) {
                self.stateStore = newValue
            }
        }
    }

    // MARK: - Properties
    open override var isReady: Bool {
        state == .ready && super.isReady
    }

    public final override var isExecuting: Bool {
        state == .executing
    }

    public final override var isFinished: Bool {
        state == .finished
    }

    public final override var isAsynchronous: Bool {
        true
    }

    // MARK: - Functions
    public override class func keyPathsForValuesAffectingValue(
        forKey key: String
    ) -> Set<String> {
        let stateKeyPaths: Set<String> = ["isReady", "isFinished", "isExecuting"]
        guard stateKeyPaths.contains(key) else {
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
        return [#keyPath(state)]
    }

    public final override func start() {
        guard !isCancelled else {
            state = .finished
            return
        }
        state = .executing
        main()
    }

    public final func finish() {
        if !isFinished {
            state = .finished
        }
    }
}
