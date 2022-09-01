import Foundation

final class MorePartitionModel: MorePartitionModelProtocol {
    // MARK: - Private properties

    // MARK: - Initialization
    init() { }

    // MARK: MorePartitionModelProtocol
    func fetchContentModel(_ mode: PartitionMode) -> PartitionContentModel {
        // TODO: Localize strings!!!
        switch mode {
        case .donate:
            return PartitionContentModel(
                header: PartitionContentModel.Header(title: "Donate"),
                content: PartitionContentModel.Content(actions: nil),
                footer: PartitionContentModel.Footer(
                    action: PartitionContentModel.Action(
                        actionId: PartitionContentModel.Action.ActionID.copyIBAN,
                        title: "Copy IBAN",
                        type: PartitionContentModel.FooterType.accent,
                        dialog: nil
                    )
                )
            )
        case .account:
            return PartitionContentModel(
                header: PartitionContentModel.Header(title: "Account"),
                content: PartitionContentModel.Content(
                    actions: [
                        PartitionContentModel.Action(
                            actionId: PartitionContentModel.Action.ActionID.none,
                            title: "Delete Account",
                            type: PartitionContentModel.FooterType.inverted,
                            dialog: PartitionContentModel.Dialog(
                                title: "Are you sure you want to delete your account?",
                                actions: [
                                    PartitionContentModel.Dialog.Action(
                                        actionId: .cancel, title: "Cancel", style: .inverted
                                    ),
                                    PartitionContentModel.Dialog.Action(
                                        actionId: .delete, title: "Delete", style: .accent
                                    )
                                ]
                            )
                        )
                    ]
                ),
                footer: PartitionContentModel.Footer(
                    action: PartitionContentModel.Action(
                        actionId: PartitionContentModel.Action.ActionID.none,
                        title: "Log out",
                        type: PartitionContentModel.FooterType.inverted,
                        dialog: PartitionContentModel.Dialog(
                            title: "Are you sure you want to log out of your account?",
                            actions: [
                                PartitionContentModel.Dialog.Action(
                                    actionId: .cancel, title: "Cancel", style: .inverted
                                ),
                                PartitionContentModel.Dialog.Action(
                                    actionId: .logout, title: "Log out", style: .accent
                                )
                            ]
                        )
                    )
                )
            )
        case .help:
            return PartitionContentModel(
                header: PartitionContentModel.Header(title: "Help"),
                content: PartitionContentModel.Content(actions: nil),
                footer: nil
            )
        case .about:
            return PartitionContentModel(
                header: PartitionContentModel.Header(title: "About"),
                content: PartitionContentModel.Content(actions: nil),
                footer: nil
            )
        }
    }
}
