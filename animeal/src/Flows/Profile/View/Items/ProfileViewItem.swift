// System
import Foundation

// SDK
import Common
import UIComponents

struct ProfileViewItemsSnapshot {
    let resetPreviousItems: Bool
    let viewItems: [ProfileViewItem]
}

struct ProfileViewItem {
    let identifier: String
    let type: ProfileItemType
    let state: ProfileItemState
    let formatter: DefaultTextInputFormatter?
    let isEditable: Bool
    let title: String
    let content: TextFieldContainerView.Model
}
