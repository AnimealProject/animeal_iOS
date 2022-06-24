import Foundation

public class SynchronizedQueue<T> {
    private let queue = DispatchQueue(label: "synchronized queue id=\(UUID().uuidString)", attributes: .concurrent)
    private var elements: [T] = []

    public var head: T? {
        var first: T?
        queue.sync {
            first = self.elements.first
        }
        return first
    }
    public var tail: T? {
        var last: T?
        queue.sync {
            last = self.elements.last
        }
        return last
    }

    public func enqueue(_ value: T) {
        queue.sync(flags: .barrier) {
            self.elements.append(value)
        }
    }

    public func dequeue() -> T? {
        guard !elements.isEmpty else {
            return nil
        }
        var element: T?
        queue.sync {
            element = self.elements.removeFirst()
        }
        return element
    }
}
