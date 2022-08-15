import Foundation
import Combine

final class VerificationModel: VerificationModelProtocol {
    // MARK: - Private properties
    private var code: VerificationModelCode
    private var expectedCode: String

    @Published private var isResendActive = false {
        didSet {
            fetchNewCodeResponse?(code)
        }
    }

    private let timeLeft: CurrentValueSubject<Int, Never>
    private let timerTimeout: Int
    private var timer: Cancellable?

    private var cancellables: Set<AnyCancellable>

    // MARK: - Dependencies

    // MARK: - Responses
    var fetchNewCodeResponse: ((VerificationModelCode) -> Void)?
    var fetchNewCodeResponseTimeLeft: ((VerificationModelTimeLeft) -> Void)?

    // MARK: - Initialization
    init() {
        self.timeLeft = CurrentValueSubject<Int, Never>(30)
        self.timerTimeout = 30
        self.cancellables = []
        self.expectedCode = "1111"
        self.code = VerificationModelCode(
            items: [
                VerificationModelCodeItem(identifier: UUID().uuidString, text: nil),
                VerificationModelCodeItem(identifier: UUID().uuidString, text: nil),
                VerificationModelCodeItem(identifier: UUID().uuidString, text: nil),
                VerificationModelCodeItem(identifier: UUID().uuidString, text: nil)
            ]
        )
        setup()
    }

    // MARK: - Deinit
    deinit {
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - Requests
    func isValidationNeeded(_ code: VerificationModelCode) -> Bool {
        let candidate = code.items.compactMap { $0.text }
        let expected = self.expectedCode
        return candidate.count == expected.count
    }

    func validateCode(_ code: VerificationModelCode) -> Bool {
        let candidate = code.items
            .compactMap { $0.text }
            .joined()
        return candidate == expectedCode
    }

    func fetchInitialCode() {
        fetchNewCodeResponse?(code)
    }

    func fetchNewCode() {
        timeLeft.send(timerTimeout)
        scheduleExpiration()
    }
}

private extension VerificationModel {
    func scheduleExpiration() {
        timer?.cancel()
        timer = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard
                    let self = self,
                    self.timeLeft.value > .zero
                else {
                    self?.timer?.cancel()
                    return
                }
                self.timeLeft.value -= 1
            }
    }

    func setup() {
        timeLeft
            .map { $0 == .zero }
            .assign(to: &$isResendActive)
        timeLeft
            .sink { [weak self] time in
                self?.fetchNewCodeResponseTimeLeft?(
                    VerificationModelTimeLeft(time: time)
                )
            }
            .store(in: &cancellables)
    }
}
