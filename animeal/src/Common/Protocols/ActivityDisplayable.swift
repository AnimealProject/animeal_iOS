// System
import UIKit

// SDK
import UIComponents

@MainActor
protocol ActivityDisplayable: AnyObject {
    var activityPresenter: ActivityIndicatorPresenter { get }

    func displayActivityIndicator(activityData: ActivityIndicatorPresenter.Model)
    func hideActivityIndicator(completion: (() -> Void)?)
}

extension ActivityDisplayable {
    func displayActivityIndicator() {
        activityPresenter.startAnimating()
    }

    func displayActivityIndicator(activityData: ActivityIndicatorPresenter.Model) {
        activityPresenter.startAnimating(activityData)
    }

    func hideActivityIndicator(completion: (() -> Void)?) {
        activityPresenter.stopAnimating()
        completion?()
    }

    func hideActivityIndicator() {
        activityPresenter.stopAnimating()
    }
}

extension ActivityDisplayable where Self: AlertCoordinatable {
    func displayActivityIndicator(
        caption: String?,
        waitUntil operation: @escaping @MainActor () async throws -> Void,
        completion: ((Bool) -> Void)?
    ) {
        displayActivityIndicator(activityData: .default(caption: caption))

        Task { @MainActor [weak self] in
            do {
                try await operation()
                self?.hideActivityIndicator()
                completion?(true)
            } catch {
                self?.hideActivityIndicator()
                self?.displayAlert(message: error.localizedDescription)
                completion?(false)
            }
        }
    }

    func displayActivityIndicator(
        waitUntil operation: @escaping @MainActor () async throws -> Void,
        completion: ((Bool) -> Void)?
    ) {
        displayActivityIndicator(
            caption: nil,
            waitUntil: operation,
            completion: completion
        )
    }

    func displayActivityIndicator(
        waitUntil operation: @escaping @MainActor () async throws -> Void
    ) {
        displayActivityIndicator(
            caption: nil,
            waitUntil: operation,
            completion: nil
        )
    }
}
