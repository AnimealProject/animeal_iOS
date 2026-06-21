import Foundation

/// Manages async state mutations with at-most-one-in-flight guarantee.
///
/// Fires the first request immediately. While a request is in flight,
/// all subsequent calls update a single pending value — coalescing them
/// into one follow-up request once the current one completes.
/// If the pending value matches the confirmed server state after completion,
/// no follow-up is sent.
@MainActor
public final class AsyncValue<T: Equatable> {

    // MARK: - Public state

    public private(set) var confirmed: T
    private var currentTarget: T?
    private var pendingValue: T?

    /// The value the UI should optimistically display.
    /// Reflects: pending → in-flight target → confirmed.
    public var intended: T { pendingValue ?? currentTarget ?? confirmed }

    // MARK: - Callbacks

    public var onConfirmed: ((T) -> Void)?
    public var onReverted: (() -> Void)?

    // MARK: - Init

    public init(
        _ initial: T,
        onConfirmed: ((T) -> Void)? = nil,
        onReverted: (() -> Void)? = nil
    ) {
        confirmed = initial
        self.onConfirmed = onConfirmed
        self.onReverted = onReverted
    }

    // MARK: - Public API

    /// Request a mutation to `desired`. Safe to call multiple times concurrently.
    public func mutate(to desired: T, via executor: @escaping (T) async throws -> T) {
        guard currentTarget == nil else {
            pendingValue = desired
            return
        }
        currentTarget = desired
        Task { @MainActor in await self.perform(desired, executor: executor) }
    }

    /// Sync the confirmed base value (e.g. from initial content load).
    /// No-op while a mutation is in flight to avoid clobbering pending state.
    public func update(confirmed value: T) {
        guard currentTarget == nil else { return }
        confirmed = value
        pendingValue = nil
    }

    // MARK: - Private

    private func perform(_ target: T, executor: @escaping (T) async throws -> T) async {
        do {
            let result = try await executor(target)
            confirmed = result
            currentTarget = nil
            onConfirmed?(result)
        } catch {
            currentTarget = nil
            onReverted?()
        }

        if let pending = pendingValue, pending != confirmed {
            pendingValue = nil
            currentTarget = pending
            await perform(pending, executor: executor)
        } else {
            pendingValue = nil
            currentTarget = nil
        }
    }
}
