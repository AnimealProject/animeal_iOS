import Foundation
import Services
import UIKit

final class MorePartitionModel: MorePartitionModelProtocol {
    // MARK: - Dependencies
    private let authenticationService: AuthenticationServiceProtocol

    // MARK: - Initialization
    init(_ context: AuthenticationServiceHolder) {
        self.authenticationService = context.authenticationService
    }

    // MARK: MorePartitionModelProtocol
    func fetchContentModel(_ mode: PartitionMode) -> PartitionContentModel {
        switch mode {
        case .donate:
            return PartitionContentModel(
                header: PartitionContentModel.Header(title: L10n.More.donate),
                content: PartitionContentModel.Content(actions: nil),
                footer: PartitionContentModel.Footer(
                    action: PartitionContentModel.Action(
                        actionId: PartitionContentModel.Action.ActionID.copyIBAN,
                        title: L10n.Action.copyIBAN,
                        type: PartitionContentModel.FooterType.accent,
                        dialog: nil
                    )
                )
            )
        case .account:
            return PartitionContentModel(
                header: PartitionContentModel.Header(title: L10n.More.account),
                content: PartitionContentModel.Content(
                    actions: [
                        PartitionContentModel.Action(
                            actionId: PartitionContentModel.Action.ActionID.none,
                            title: L10n.Action.deleteAccount,
                            type: PartitionContentModel.FooterType.inverted,
                            dialog: PartitionContentModel.Dialog(
                                title: L10n.Question.deleteAccount,
                                actions: [
                                    PartitionContentModel.Dialog.Action(
                                        actionId: .cancel, title: L10n.Action.cancel, style: .inverted
                                    ),
                                    PartitionContentModel.Dialog.Action(
                                        actionId: .delete, title: L10n.Action.delete, style: .accent
                                    )
                                ]
                            )
                        )
                    ]
                ),
                footer: PartitionContentModel.Footer(
                    action: PartitionContentModel.Action(
                        actionId: PartitionContentModel.Action.ActionID.none,
                        title: L10n.Action.logOut,
                        type: PartitionContentModel.FooterType.inverted,
                        dialog: PartitionContentModel.Dialog(
                            title: L10n.Question.logoutAccount,
                            actions: [
                                PartitionContentModel.Dialog.Action(
                                    actionId: .cancel, title: L10n.Action.cancel, style: .inverted
                                ),
                                PartitionContentModel.Dialog.Action(
                                    actionId: .logout, title: L10n.Action.logOut, style: .accent
                                )
                            ]
                        )
                    )
                )
            )
        case .faq:
            return PartitionContentModel(
                header: PartitionContentModel.Header(title: L10n.More.faq),
                content: PartitionContentModel.Content(actions: nil),
                footer: nil
            )
        case .about:
            return PartitionContentModel(
                header: PartitionContentModel.Header(title: L10n.More.aboutShort),
                content: PartitionContentModel.Content(
                    bottomTextBlock: PartitionContentModel.TextBlock(title: "\(L10n.About.appVersion) \(AppInfo.appVersion)")
                ),
                footer: nil
            )
        }
    }

    func handleSignOut(completion: ((Result<Void, Error>) -> Void)?) {
        authenticationService.signOut { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion?(.success(()))
                case .failure(let error):
                    logError("\(error)")
                    completion?(.failure(error))
                }
            }
        }
    }

    func handleDeleteUser(completion: ((Result<Void, Error>) -> Void)?) {
        authenticationService.deleteUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion?(.success(()))
                case .failure(let error):
                    logError("\(error)")
                    completion?(.failure(error))
                }
            }
        }
    }

    func handleCopyIBAN() {
        UIPasteboard.general.string = "Animeal IBAN placeholder"
    }
}
