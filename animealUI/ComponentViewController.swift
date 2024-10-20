import Foundation
import UIKit
import UIComponents

class ComponentViewController<T: UIView>: UIViewController {
    typealias Element = T

    // MARK: - Views
    private var element: Element!

    // MARK: - Public props
    var configureElement: ((Element) -> Void)?

    // MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureAppearance()
        configureElement?(element)

        let dismissGesture = TapGestureRecognizer { [weak self] _ in
            self?.view.endEditing(true)
        }
        view.addGestureRecognizer(dismissGesture)
    }

    // MARK: - Private interface
    private func configureUI() {
        element = Element()
        view.addSubview(element.prepareForAutoLayout())
    }

    private func configureAppearance() {
        view.backgroundColor = designEngine.colors.backgroundPrimary
        navigationItem.largeTitleDisplayMode = .never
        title = String(reflecting: T.self)
    }
}
