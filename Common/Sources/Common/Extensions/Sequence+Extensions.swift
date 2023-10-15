import Foundation

public extension Sequence {
    /// Returns the result of combining the elements of the asynchronous sequence using the given closure, given a mutable initial value.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value. The `nextPartialResult` closure receives `initialResult` the first time the closure executes.
    ///   - nextPartialResult: A closure that combines an accumulating value and an element of the asynchronous sequence into a new accumulating value, for use in the next call of the `nextPartialResult closure or returned to the caller.
    /// - Returns: The final accumulated value. If the sequence has no elements, the result is `initialResult`.
    func asyncReduce<Result>(
        _ initialResult: Result,
        _ nextPartialResult: ((Result, Element) async throws -> Result)
    ) async rethrows -> Result {
        var result = initialResult
        for element in self {
            result = try await nextPartialResult(result, element)
        }
        return result
    }

    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
