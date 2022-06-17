import UIKit
import UIComponents
import Style

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
        dataSource.append(ComponentPresentation(description: "TabBarController", viewController: {
            TabBarControllerAssembler.assembly()
        }))

        dataSource.append(ComponentPresentation(description: "OnboardingView", viewController: {
            let viewController = ComponentViewController<OnboardingView>()
            viewController.configureElement = { element in
                let superView = element.superview!
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
        }))

        dataSource.append(ComponentPresentation(description: "ButtonContainerView", viewController: {
            let viewController = ComponentViewController<ButtonContainerView>()
            viewController.configureElement = { element in
                let superView = element.superview!

                element.leadingAnchor ~= superView.leadingAnchor
                element.trailingAnchor ~= superView.trailingAnchor
                element.centerYAnchor ~= superView.centerYAnchor
                element.centerXAnchor ~= superView.centerXAnchor

                element.configure(
                    ButtonContainerView.Model(buttons: [
                        ButtonViewModel(
                            identifier: "Sign in with Mobile",
                            viewType: SignInWithMobileButtonView.self,
                            icon: Asset.Images.signInMobile.image,
                            title: "Sign in with Mobile"),
                        ButtonViewModel(
                            identifier: "Sign in with Facebook",
                            viewType: SignInWithFacebookButtonView.self,
                            icon: Asset.Images.signInFacebook.image,
                            title: "Sign in with Facebook"),
                        ButtonViewModel(
                            identifier: "Sign in with Apple",
                            viewType: SignInWithAppleButtonView.self,
                            icon: Asset.Images.signInApple.image,
                            title: "Sign in with Apple")
                        ]
                ))
                element.onTap = { [weak self] identifier in
                    self?.showAlert(title: identifier)
                }
            }
            return viewController
        }))
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