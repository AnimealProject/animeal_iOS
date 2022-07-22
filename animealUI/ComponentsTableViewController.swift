import UIKit
import UIComponents
import Style

// swiftlint:disable function_body_length

class ComponentsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Private props
    private let tableView = UITableView()
    private var dataSource: [ComponentPresentation] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "UI Components"
        view.backgroundColor = designEngine.colors.primary.uiColor
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
    }

    private func composeDataSource() {
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
                        icon:  Asset.Images.signInApple.image,
                        title: "Sign in with Apple"
                    )
                    let signInWithAppleButtonView = buttonsFactory.makeSignInWithAppleButton()
                    signInWithAppleButtonView.condifure(signInWithAppleModel)

                    let signInWithMobileModel = ButtonView.Model(
                        identifier: "signInWithMobileButton",
                        viewType: ButtonView.self,
                        icon:  Asset.Images.signInMobile.image,
                        title: "Sign in with Mobile"
                    )
                    let signInWithMobileButton = buttonsFactory.makeSignInWithMobileButton()
                    signInWithMobileButton.condifure(signInWithMobileModel)

                    let signInWithFacebookModel = ButtonView.Model(
                        identifier: "signInWithFacebookButton",
                        viewType: ButtonView.self,
                        icon:  Asset.Images.signInFacebook.image,
                        title: "Sign in with Facebook"
                    )
                    let signInWithFacebookButton = buttonsFactory.makeSignInWithFacebookButton()
                    signInWithFacebookButton.condifure(signInWithFacebookModel)

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
                    let action = { identifier in
                        print(identifier)
                    }
                    element.configure(
                        SegmentedControl.Model(
                            items: [
                                SegmentedControl.Item(identifier: 0, title: "Dogs", action: action),
                                SegmentedControl.Item(identifier: 1, title: "Cats", action: action)
                            ]
                        )
                    )
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
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(
            dataSource[indexPath.row].viewController(), animated: true
        )
    }
}

// MARK: - ComponentPresentation
private struct ComponentPresentation {
    let description: String
    let viewController: (() -> UIViewController)
}
