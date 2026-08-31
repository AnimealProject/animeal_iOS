import UIKit
import UIComponents

final class ___VARIABLE_productName:identifier___ViewController: UIViewController, ___VARIABLE_productName:identifier___Viewable, ScreenAccessible {
    static var screenIdentifier: String { ___VARIABLE_productName:identifier___ViewModel.AccessibilityID.screen }

    // MARK: - UI properties
    private let viewModel: ___VARIABLE_productName:identifier___ViewModelProtocol

    // MARK: - Initialization
    init(viewModel: ___VARIABLE_productName:identifier___ViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyScreenIdentifier()
        setup()
        viewModel.load()
    }

    // MARK: - Setup
    private func setup() {
    }
}
