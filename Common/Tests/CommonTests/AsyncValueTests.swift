import Testing
import Foundation.NSURLError
@testable import Common

@MainActor
@Suite("AsyncValue")
struct AsyncValueTests {

    // MARK: - Immediate dispatch

    @Test("fires first request immediately without waiting")
    func firstRequestImmediate() async throws {
        var received: [Bool] = []
        let sut = AsyncValue(false)

        sut.mutate(to: true) { value in
            received.append(value)
            return value
        }

        try await Task.sleep(for: .milliseconds(20))
        #expect(received == [true])
        #expect(sut.confirmed == true)
    }

    // MARK: - Coalescing

    @Test("concurrent taps produce at most one follow-up request")
    func coalescesIntoOneFollowUp() async throws {
        var received: [Bool] = []
        let sut = AsyncValue(false)
        let slow: (Bool) async throws -> Bool = {
            received.append($0)
            try await Task.sleep(for: .milliseconds(80))
            return $0
        }

        sut.mutate(to: true, via: slow)
        try await Task.sleep(for: .milliseconds(10))
        sut.mutate(to: false, via: slow)
        sut.mutate(to: true, via: slow)
        sut.mutate(to: false, via: slow)

        try await Task.sleep(for: .milliseconds(300))
        #expect(received == [true, false])
        #expect(sut.confirmed == false)
    }

    @Test("no follow-up when pending matches confirmed after first request")
    func noFollowUpWhenPendingMatchesConfirmed() async throws {
        var count = 0
        let sut = AsyncValue(false)
        let slow: (Bool) async throws -> Bool = {
            count += 1
            try await Task.sleep(for: .milliseconds(80))
            return $0
        }

        sut.mutate(to: true, via: slow)
        try await Task.sleep(for: .milliseconds(10))
        sut.mutate(to: false, via: slow)
        sut.mutate(to: true, via: slow)  // pending = true = what first request confirms

        try await Task.sleep(for: .milliseconds(300))
        #expect(count == 1)
        #expect(sut.confirmed == true)
    }

    // MARK: - intended

    @Test("intended reflects in-flight target immediately after first tap")
    func intendedAfterFirstTap() async throws {
        let sut = AsyncValue(false)
        let slow: (Bool) async throws -> Bool = {
            try await Task.sleep(for: .milliseconds(100))
            return $0
        }

        sut.mutate(to: true, via: slow)
        #expect(sut.intended == true)
    }

    @Test("intended updates to pending value on subsequent taps")
    func intendedUpdatesToPending() async throws {
        let sut = AsyncValue(false)
        let slow: (Bool) async throws -> Bool = {
            try await Task.sleep(for: .milliseconds(100))
            return $0
        }

        sut.mutate(to: true, via: slow)
        try await Task.sleep(for: .milliseconds(10))
        sut.mutate(to: false, via: slow)
        #expect(sut.intended == false)

        sut.mutate(to: true, via: slow)
        #expect(sut.intended == true)
    }

    // MARK: - Error handling

    @Test("reverts confirmed state and calls onReverted on error")
    func revertsOnError() async throws {
        var reverted = false
        let sut = AsyncValue(false)
        sut.onReverted = { reverted = true }

        sut.mutate(to: true) { _ in throw URLError(.networkConnectionLost) }

        try await Task.sleep(for: .milliseconds(20))
        #expect(reverted == true)
        #expect(sut.confirmed == false)
    }

    @Test("processes follow-up request even after first request fails")
    func followUpAfterError() async throws {
        var received: [Bool] = []
        var callCount = 0
        let sut = AsyncValue(false)

        let failFirstThenSucceed: (Bool) async throws -> Bool = {
            callCount += 1
            received.append($0)
            if callCount == 1 { throw URLError(.networkConnectionLost) }
            return $0
        }

        sut.mutate(to: true, via: failFirstThenSucceed)
        try await Task.sleep(for: .milliseconds(10))
        sut.mutate(to: false, via: failFirstThenSucceed)

        try await Task.sleep(for: .milliseconds(100))
        #expect(received == [true, false])
        #expect(sut.confirmed == false)
    }

    // MARK: - update(confirmed:)

    @Test("update(confirmed:) resets base state when idle")
    func updateConfirmedWhenIdle() async throws {
        let sut = AsyncValue(false)
        sut.update(confirmed: true)
        #expect(sut.confirmed == true)
        #expect(sut.intended == true)
    }

    @Test("update(confirmed:) is ignored while mutation is in flight")
    func updateConfirmedIgnoredDuringMutation() async throws {
        let sut = AsyncValue(false)
        let slow: (Bool) async throws -> Bool = {
            try await Task.sleep(for: .milliseconds(100))
            return $0
        }

        sut.mutate(to: true, via: slow)
        try await Task.sleep(for: .milliseconds(10))
        sut.update(confirmed: false)  // should be ignored

        #expect(sut.confirmed == false)   // hasn't updated from executor yet
        #expect(sut.intended == true)     // still targeting true

        try await Task.sleep(for: .milliseconds(150))
        #expect(sut.confirmed == true)    // executor result wins
    }

    // MARK: - onConfirmed callback

    @Test("onConfirmed called with server result after each completed mutation")
    func onConfirmedCallback() async throws {
        var confirmed: [Bool] = []
        let sut = AsyncValue(false)
        sut.onConfirmed = { confirmed.append($0) }
        let slow: (Bool) async throws -> Bool = {
            try await Task.sleep(for: .milliseconds(50))
            return $0
        }

        sut.mutate(to: true, via: slow)
        try await Task.sleep(for: .milliseconds(10))
        sut.mutate(to: false, via: slow)

        try await Task.sleep(for: .milliseconds(200))
        #expect(confirmed == [true, false])
    }
}
