import UIKit
import Foundation
import Combine

open class BaseViewController: UIViewController {

    // MARK: - Private properties
    private var cancellables: Set<AnyCancellable> = []
    private var keyboardData = KeyboardData() {
        didSet {
            handleKeyboardNotification(keyboardData: keyboardData)
        }
    }

    // MARK: - Public methods

    /// Sets up keyboard handling for given UIViewController subclass.
    /// This method should be called in the beginning of lifecycle, for
    /// example, in viewDidLoad() or viewWillAppear()
    ///
    /// - Parameters:
    ///   - cancelsTouchesInView: A Boolean value affecting whether touches
    ///    are delivered to a view when a gesture is recognized.
    public func setupKeyboardHandling(cancelsTouchesInView: Bool = false) {
        addHideKeyboardBehaviourWhenTappedOutside(cancelsTouchesInView: cancelsTouchesInView)
        observeKeyboardNotifications()
    }

    /// Method should be overridden in subclass in order to update view
    /// layout according to the keyboard changes. For example:
    ///
    ///     public override func handleKeyboardNotification(keyboardData: KeyboardData) {
    ///         ...
    ///         let newHeight = keyboardData.keyboardRect.height + view.safeAreaInsets.bottom
    ///         scrollView.contentInset.bottom = newHeight
    ///         scrollView.verticalScrollIndicatorInsets.bottom = newHeight
    ///
    ///         let scrollPoint = CGPoint(x: 0, y: newHeight)
    ///         scrollView.setContentOffset(scrollPoint, animated: true)
    ///         ...
    ///     }
    ///
    /// - Parameters:
    ///   - keyboardData: contains info about keyboard frame and animations
    open func handleKeyboardNotification(keyboardData: KeyboardData) {}

    // MARK: - Private methods

    private func addHideKeyboardBehaviourWhenTappedOutside(cancelsTouchesInView: Bool) {
        let tapGesture = TapGestureRecognizer { [weak self] _ in
            self?.view.endEditing(true)
        }
        tapGesture.cancelsTouchesInView = cancelsTouchesInView
        view.addGestureRecognizer(tapGesture)
    }

    private func observeKeyboardNotifications() {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        )
        .removeDuplicates(by: { $0.name == $1.name })
        .sink(receiveValue: { notification in
            self.keyboardData = notification.keyboardData(
                isHiding: notification.name == UIResponder.keyboardWillHideNotification
            )
        })
        .store(in: &self.cancellables)
    }

    deinit {
        self.cancellables.forEach { $0.cancel() }
    }
}
