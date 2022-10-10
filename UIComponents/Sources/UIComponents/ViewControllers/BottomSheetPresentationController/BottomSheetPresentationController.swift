import UIKit

/// BottomSheetPresentationController provides botomsheet like transition between view controllers.
/// After `iOS 16` could be replased with `UISheetPresentationController`
///
/// Usage example:
///
///     let viewControllerToPresent = ViewControllerToPresent()
///     let controller = BottomSheetPresentationController(controller: viewController)
///     controller.modalPresentationStyle = .overFullScreen
///
///     navigator.present(controller, animated: false, completion: nil)
///
///
@available(iOS, deprecated: 16, message: "Please migrate to UISheetPresentationController")
public class BottomSheetPresentationController: UIViewController {
    // MARK: - UI Properties
    private let contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12.0
        return stackView
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = configuration.maxDimmedAlpha
        return view
    }()

    // MARK: - Private properties
    private let configuration: BottomSheetConfiguration
    private var currentContainerHeight: CGFloat
    private var containerViewHeightConstraint: NSLayoutConstraint?
    private var containerViewBottomConstraint: NSLayoutConstraint?

    // MARK: - Initialization
    public init(
        controller: UIViewController,
        configuration: BottomSheetConfiguration = BottomSheetConfiguration.default
    ) {
        self.configuration = configuration
        currentContainerHeight = configuration.defaultHeight
        super.init(nibName: nil, bundle: nil)

        contentStackView.addArrangedSubview(controller.view)
        addChild(controller)
        controller.didMove(toParent: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupGestures()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }

    // MARK: - Public API
    public func dismissView(completion: (() -> Void)?) {
        animateDismissView(completion: completion)
    }
}

private extension BottomSheetPresentationController {
    // MARK: - Setup
    func setupView() {
        view.backgroundColor = .clear
    }

    func setupConstraints() {
        view.addSubview(dimmedView.prepareForAutoLayout())
        view.addSubview(containerView.prepareForAutoLayout())
        containerView.addSubview(contentStackView.prepareForAutoLayout())

        dimmedView.topAnchor ~= view.topAnchor
        dimmedView.bottomAnchor ~= view.bottomAnchor
        dimmedView.leadingAnchor ~= view.leadingAnchor
        dimmedView.trailingAnchor ~= view.trailingAnchor

        containerView.leadingAnchor ~= view.leadingAnchor
        containerView.trailingAnchor ~= view.trailingAnchor

        contentStackView.topAnchor ~= containerView.topAnchor
        contentStackView.bottomAnchor ~= containerView.bottomAnchor
        contentStackView.leadingAnchor ~= containerView.leadingAnchor
        contentStackView.trailingAnchor ~= containerView.trailingAnchor

        // Set dynamic constraints
        // First, set container to default height
        // after panning, the height can expand
        containerViewHeightConstraint = containerView.heightAnchor.constraint(
            equalToConstant: configuration.defaultHeight
        )
        // By setting the height to default height, the container will be hide below the bottom anchor view
        // Later, will bring it up by set it to 0
        // set the constant to default height to bring it down again
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: configuration.defaultHeight
        )
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }

    func setupGestures() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
    }

    @objc func handleCloseAction() {
        animateDismissView(completion: nil)
    }

    // MARK: - Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        // Get drag direction
        let isDraggingDown = translation.y > 0

        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y

        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < configuration.maximumContainerHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container

            // Condition 1: If new height is below min, dismiss controller
            if newHeight < configuration.dismissibleHeight {
                self.animateDismissView(completion: nil)
            } else if newHeight < configuration.defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(configuration.defaultHeight)
            } else if newHeight < configuration.maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(configuration.defaultHeight)
            } else if newHeight > configuration.defaultHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(configuration.maximumContainerHeight)
            }
        default:
            break
        }
    }

    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }

    // MARK: - Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }

    func animateShowDimmedView() {
         dimmedView.alpha = 0
         UIView.animate(withDuration: 0.4) {
             self.dimmedView.alpha = self.configuration.maxDimmedAlpha
         }
    }

    func animateDismissView(completion: (() -> Void)?) {
        // hide blur view
        dimmedView.alpha = configuration.maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false, completion: completion)
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.configuration.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
}
