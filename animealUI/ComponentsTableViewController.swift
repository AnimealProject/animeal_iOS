import UIKit
import UIComponents
import Style

// swiftlint:disable function_body_length
// swiftlint:disable type_body_length

// MARK: - ComponentPresentation
private struct ComponentPresentation {
    let description: String
    let viewController: (() -> UIViewController)
}

class ComponentsTableViewController: UIViewController,
                                     UITableViewDataSource,
                                     UITableViewDelegate {
    // MARK: - Private props
    private let tableView = UITableView()
    private var dataSource: [ComponentPresentation] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "UI Components"
        view.backgroundColor = designEngine.colors.backgroundPrimary.uiColor
        addSubviews()
        composeDataSource()
    }

    // MARK: - Private interface
    private func addSubviews() {
        view.addSubview(tableView.prepareForAutoLayout())

        tableView.leadingAnchor ~= view.leadingAnchor
        tableView.trailingAnchor ~= view.trailingAnchor
        tableView.topAnchor ~= view.topAnchor
        tableView.bottomAnchor ~= view.bottomAnchor

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self

        tableView.backgroundColor = designEngine.colors.backgroundPrimary.uiColor
    }

    private func composeDataSource() {
        dataSource.append(
            ComponentPresentation(
                description: "AlertViewController"
            ) { [weak self] in
                guard let self = self else { fatalError("Failed to unwrap self") }
                let viewController = ComponentViewController<UIStackView>()
                viewController.configureElement = { element in
                    guard let superView = element.superview else {
                        return
                    }
                    element.centerYAnchor ~= superView.centerYAnchor
                    element.centerXAnchor ~= superView.centerXAnchor
                    element.axis = .vertical
                    element.spacing = 30

                    let doubleActionButton = UIButton(type: .system)
                    doubleActionButton.setTitle("doubleActionAlert", for: .normal)
                    doubleActionButton.addTarget(self, action: #selector(self.doubleActionAlert), for: .touchUpInside)

                    let singleActionButton = UIButton(type: .system)
                    singleActionButton.setTitle("singleActionAlert", for: .normal)
                    singleActionButton.addTarget(self, action: #selector(self.singleActionAlert), for: .touchUpInside)

                    let imageWithActionsButton = UIButton(type: .system)
                    imageWithActionsButton.setTitle("imagesWithActionsAlert", for: .normal)
                    imageWithActionsButton.addTarget(
                        self, action: #selector(self.imageWithActionsAlert), for: .touchUpInside
                    )

                    element.addArrangedSubview(doubleActionButton)
                    element.addArrangedSubview(singleActionButton)
                    element.addArrangedSubview(imageWithActionsButton)
                }
                return viewController
            }
        )

        dataSource.append(
            ComponentPresentation(
                description: "TabBarController"
            ) {
                TabBarControllerAssembler.assembly()
            }
        )

        dataSource.append(
            ComponentPresentation(
                description: "OnboardingView"
            ) {
                let viewController = ComponentViewController<OnboardingView>()
                viewController.configureElement = { element in
                    guard let superView = element.superview else {
                        return
                    }

                    element.heightAnchor ~= 500
                    element.leadingAnchor ~= superView.leadingAnchor
                    element.trailingAnchor ~= superView.trailingAnchor
                    element.centerYAnchor ~= superView.centerYAnchor
                    element.configure(
                        OnboardingView.Model(
                            steps: [
                                OnboardingView.Step(
                                    identifier: UUID().uuidString,
                                    image: Asset.Images.onboardingFeed.image,
                                    title: "Take care of pets",
                                    text: "Some of them are homeless, they need your help"
                                ),
                                OnboardingView.Step(
                                    identifier: UUID().uuidString,
                                    image: Asset.Images.onboardingFeed.image,
                                    title: "Take care of pets",
                                    text: "Some of them are homeless, they need your help"
                                ),
                                OnboardingView.Step(
                                    identifier: UUID().uuidString,
                                    image: Asset.Images.onboardingFeed.image,
                                    title: "Take care of pets",
                                    text: "Some of them are homeless, they need your help"
                                )
                            ]
                        )
                    )
                }
                return viewController
            }
        )

        dataSource.append(
            ComponentPresentation(
                description: "ButtonContainerView"
            ) {
                let viewController = ComponentViewController<ButtonContainerView>()
                viewController.configureElement = { element in
                    guard let superView = element.superview else {
                        return
                    }

                    element.leadingAnchor ~= superView.leadingAnchor
                    element.trailingAnchor ~= superView.trailingAnchor
                    element.centerYAnchor ~= superView.centerYAnchor
                    element.centerXAnchor ~= superView.centerXAnchor

                    let buttonsFactory = ButtonViewFactory()
                    let signInWithAppleModel = ButtonView.Model(
                        identifier: "signInWithAppleButton",
                        viewType: ButtonView.self,
                        icon: Asset.Images.signInApple.image,
                        title: "Sign in with Apple"
                    )
                    let signInWithAppleButtonView = buttonsFactory.makeSignInWithAppleButton()
                    signInWithAppleButtonView.configure(signInWithAppleModel)

                    let signInWithMobileModel = ButtonView.Model(
                        identifier: "signInWithMobileButton",
                        viewType: ButtonView.self,
                        icon: Asset.Images.signInMobile.image,
                        title: "Sign in with Mobile"
                    )
                    let signInWithMobileButton = buttonsFactory.makeSignInWithMobileButton()
                    signInWithMobileButton.configure(signInWithMobileModel)

                    let signInWithFacebookModel = ButtonView.Model(
                        identifier: "signInWithFacebookButton",
                        viewType: ButtonView.self,
                        icon: Asset.Images.signInFacebook.image,
                        title: "Sign in with Facebook"
                    )
                    let signInWithFacebookButton = buttonsFactory.makeSignInWithFacebookButton()
                    signInWithFacebookButton.configure(signInWithFacebookModel)

                    element.configure([
                        signInWithAppleButtonView,
                        signInWithMobileButton,
                        signInWithFacebookButton
                    ])

                    element.onTap = { [weak self] identifier in
                        self?.showAlert(title: identifier)
                    }
                }
                return viewController
            }
        )

        dataSource.append(
            ComponentPresentation(
                description: "CircleButtonView"
            ) {
                let viewController = ComponentViewController<UIView>()
                viewController.configureElement = { element in
                    guard let superView = element.superview else {
                        return
                    }

                    element.centerYAnchor ~= superView.centerYAnchor
                    element.centerXAnchor ~= superView.centerXAnchor
                    element.widthAnchor ~= superView.widthAnchor
                    element.heightAnchor ~= superView.heightAnchor

                    let model = CircleButtonView.Model(
                        identifier: "myLocationButton",
                        viewType: CircleButtonView.self,
                        icon: Asset.Images.findLocation.image
                    )
                    let buttonsFactory = ButtonViewFactory()
                    let myLocationButton = buttonsFactory.makeMyLocationButton()
                    myLocationButton.configure(model)
                    myLocationButton.onTap = { identifier in
                        print(identifier)
                    }
                    element.addSubview(myLocationButton.prepareForAutoLayout())
                    myLocationButton.centerXAnchor ~= element.centerXAnchor
                    myLocationButton.centerYAnchor ~= element.centerYAnchor
                }
                return viewController
            }
        )

        dataSource.append(
            ComponentPresentation(
                description: "SegmentedControl"
            ) {
                let viewController = ComponentViewController<SegmentedControl>()
                viewController.configureElement = { element in
                    guard let superView = element.superview else {
                        return
                    }

                    element.centerYAnchor ~= superView.centerYAnchor
                    element.centerXAnchor ~= superView.centerXAnchor
                    element.widthAnchor ~= 226
                    element.configure(
                        SegmentedControl.Model(
                            items: [
                                SegmentedControl.Item(identifier: 0, title: "Dogs"),
                                SegmentedControl.Item(identifier: 1, title: "Cats")
                            ]
                        )
                    )
                    element.onTap = { identifier in
                        print(identifier)
                    }
                }
                return viewController
            }
        )

        dataSource.append(
            ComponentPresentation(
                description: "FeedingPointView"
            ) {
                let viewController = ComponentViewController<FeedingPointView>()
                viewController.configureElement = { element in
                    guard let superView = element.superview else {
                        return
                    }

                    element.centerYAnchor ~= superView.centerYAnchor
                    element.centerXAnchor ~= superView.centerXAnchor
                    element.configure(
                        FeedingPointView.Model(
                            identifier: UUID().uuidString,
                            isSelected: false,
                            kind: FeedingPointView.Kind.dog(.high)
                        )
                    )
                    element.tapAction = { identifier in
                        print(identifier)
                    }
                }
                return viewController
            }
        )

        dataSource.append(
            ComponentPresentation(
                description: "FeedingPointViews"
            ) {
                let viewController = ComponentViewController<UIStackView>()
                viewController.configureElement = { stackView in
                    guard let superView = stackView.superview else {
                        return
                    }

                    stackView.leadingAnchor ~= superView.leadingAnchor + 20
                    stackView.trailingAnchor ~= superView.trailingAnchor - 20
                    stackView.centerYAnchor ~= superView.centerYAnchor
                    stackView.centerXAnchor ~= superView.centerXAnchor
                    stackView.axis = .vertical
                    stackView.spacing = 16

                    let infoView = PlaceInfoView()
                    stackView.addArrangedSubview(infoView)
                    infoView.configure(PlaceInfoView.Model(
                        icon: Asset.Images.cityLogo.image,
                        title: "Near to Bukia Garden M.S Technical University",
                        status: StatusView.Model(status: .attention("There is no food"))
                    ))

                    let paragraphView = TextParagraphView()
                    stackView.addArrangedSubview(paragraphView)
                    paragraphView.configure(
                        TextParagraphView.Model(
                            title: "This area covers about 100 sq.m. -S,"
                            + " it starts with Bukia Garden and Sports At the palace."
                            + " There are about 1000 homeless people here The dog lives with the habit"
                            + "of helping You need."
                        )
                    )

                    let title = TextTitleView()
                    title.configure(TextTitleView.Model(title: "Last feeder"))
                    stackView.addArrangedSubview(title)

                    let feeder = FeederView()
                    stackView.addArrangedSubview(feeder)
                    feeder.configure(
                        FeederView.Model(
                            title: "Giorgi Abutidze",
                            subtitle: "14 hours ago",
                            icon: Asset.Images.feederPlaceholderIcon.image
                        )
                    )
                    let feeder1 = FeederView()
                    stackView.addArrangedSubview(feeder1)
                    feeder1.configure(
                        FeederView.Model(
                            title: "Giorgi Abutidze",
                            subtitle: "14 hours ago",
                            icon: Asset.Images.feederPlaceholderIcon.image
                        )
                    )
                    let feeder2 = FeederView()
                    stackView.addArrangedSubview(feeder2)
                    feeder2.configure(
                        FeederView.Model(
                            title: "Giorgi Abutidze",
                            subtitle: "14 hours ago",
                            icon: Asset.Images.feederPlaceholderIcon.image
                        )
                    )
                    let feeder3 = FeederView()
                    stackView.addArrangedSubview(feeder3)
                    feeder3.configure(
                        FeederView.Model(
                            title: "Giorgi Abutidze",
                            subtitle: "14 hours ago",
                            icon: Asset.Images.feederPlaceholderIcon.image
                        )
                    )
                }
                return viewController
            }
        )

        dataSource.append(
            ComponentPresentation(
                description: "FeedingControlView"
            ) {
                let viewController = ComponentViewController<UIView>()
                viewController.configureElement = { element in
                    guard let superView = element.superview else {
                        return
                    }
                    superView.backgroundColor = .lightGray

                    let feedingControllerView = FeedingControlView(
                        timerProvider: FeedingTimerProvider(
                            configuration: FeedingTimerProvider.Configuration(timerInterval: 1, countdownInterval: 239)
                        )
                    )
                    superView.addSubview(feedingControllerView.prepareForAutoLayout())
                    feedingControllerView.centerYAnchor ~= superView.centerYAnchor
                    feedingControllerView.centerXAnchor ~= superView.centerXAnchor

                    feedingControllerView.updateDistance(4560)

                    feedingControllerView.onCloseHandler = {
                        print("onCloseHandler")
                    }
                    feedingControllerView.onTimerFinishHandler = {
                        print("onTimerFinishHandler")
                    }
                }
                return viewController
            }
        )
    }

    private func showAlert(title: String = "Title", message: String = "Message") {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        controller.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(controller, animated: true)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = dataSource[indexPath.row].description
        cell.backgroundColor = designEngine.colors.backgroundPrimary.uiColor
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(
            dataSource[indexPath.row].viewController(), animated: true
        )
    }
}

// MARK: - AlertViewController helpers
private extension ComponentsTableViewController {
    @objc func doubleActionAlert() {
        let alert = AlertViewController(title: "Do you really want to discard the changes?")
        alert.addAction(
            AlertAction(title: "No", style: AlertAction.Style.inverted) {
                print("No")
                alert.dismiss(animated: true)
            }
        )
        alert.addAction(
            AlertAction( title: "Yes", style: AlertAction.Style.accent) {
                print("yes")
                alert.dismiss(animated: true)
            }
        )
        present(alert, animated: true)
    }

    @objc func singleActionAlert() {
        let alert = AlertViewController(
            title: "Your feeding timer is over.You can book a new feeding from the home page."
        )
        alert.addAction(
            AlertAction(title: "Got it", style: AlertAction.Style.accent) {
                print("Got it")
                alert.dismiss(animated: true)
            }
        )
        present(alert, animated: true)
    }

    @objc func imageWithActionsAlert() {
        let alert = AlertViewController(
            title: "Are you sure you want to delete this photo? ",
            image: Asset.Images.dogWhileEating.image
        )
        alert.addAction(
            AlertAction(title: "No", style: AlertAction.Style.inverted) {
                print("No")
                alert.dismiss(animated: true)
            }
        )
        alert.addAction(
            AlertAction(title: "Yes", style: AlertAction.Style.accent) {
                print("yes")
                alert.dismiss(animated: true)
            }
        )
        present(alert, animated: true)
    }
}

// swiftlint:enable function_body_length
// swiftlint:enable type_body_length
