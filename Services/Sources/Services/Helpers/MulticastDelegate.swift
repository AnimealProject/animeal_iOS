import Foundation

public class MulticastDelegate<T> {
    private var lock = DispatchSemaphore(value: 1)
    private var delegates = NSHashTable<AnyObject>(options: [.objectPointerPersonality, .weakMemory])

    // swiftlint:disable empty_count
    public var isEmpty: Bool {
        var result: Bool
        lock.wait()
        result = delegates.count == 0
        lock.signal()
        return result
    }
    // swiftlint:enable empty_count

    // MARK: - Public methods
    public func addDelegate(_ delegate: T) {
        lock.wait()
        if !delegates.contains(delegate as AnyObject) {
            delegates.add(delegate as AnyObject)
        }
        lock.signal()
    }

    public func removeDelegate(_ delegate: T) {
        lock.wait()
        delegates.remove(delegate as AnyObject)
        lock.signal()
    }

    public func removeAllDelegates() {
        lock.wait()
        delegates.removeAllObjects()
        lock.signal()
    }

    public func invokeDelegates(_ invocation: (T) -> Void) {
        lock.wait()
        let delegates = self.delegates.allObjects
        lock.signal()
        for delegate in delegates {
            guard let object = delegate as? T else {
                fatalError("Cast to \(T.self) error!")
            }
            invocation(object)
        }
    }

    public func containsDelegate(_ delegate: T) -> Bool {
        var result: Bool
        lock.wait()
        result = delegates.contains(delegate as AnyObject)
        lock.signal()
        return result
    }
}
