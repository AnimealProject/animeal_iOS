// System
import Foundation

// SDK
import Common
import UIComponents

struct CustomAuthViewItem {
    let identifier: String
    let type: CustomAuthItemType
    let state: CustomAuthItemState
    let formatter: PlaceholderTextInputFormatter?
    let isEditable: Bool
    let title: String
    let content: TextFieldContainerView.Model
}
