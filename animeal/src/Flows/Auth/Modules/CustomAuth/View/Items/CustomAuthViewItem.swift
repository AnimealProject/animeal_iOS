// System
import Foundation

// SDK
import Common
import UIComponents

struct CustomAuthUpdateViewItemsSnapshot {
    let resetPreviousItems: Bool
    let viewItems: [CustomAuthViewItem]
}

struct CustomAuthViewItem {
    let identifier: String
    let type: CustomAuthItemType
    let state: CustomAuthItemState
    let formatter: DefaultTextInputFormatter?
    let isEditable: Bool
    let title: String
    let content: TextFieldContainerView.Model
}
