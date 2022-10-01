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

@MainActor
protocol ActivityDisplayCompatible: AnyObject {
    var onActivityIsNeededToDisplay: ((@escaping @MainActor () async throws -> Void) -> Void)? { get set }
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

extension ActivityDisplayable where Self: UIViewController & ErrorDisplayable {
    func displayActivityIndicator(
        caption: String?,
        waitUntil operation: @escaping @MainActor () async throws -> Void,
        completion: (() -> Void)?
    ) {
        displayActivityIndicator(activityData: .default(caption: caption))

        Task { @MainActor [weak self] in
            do {
                try await operation()
                self?.hideActivityIndicator()
                completion?()
            } catch {
                self?.hideActivityIndicator()
                self?.displayError(error.localizedDescription)
                completion?()
            }
        }
    }

    func displayActivityIndicator(
        waitUntil operation: @escaping @MainActor () async throws -> Void,
        completion: (() -> Void)?
    ) {
        displayActivityIndicator(
            caption: nil,
            waitUntil: operation,
            completion: completion
        )
    }
}
