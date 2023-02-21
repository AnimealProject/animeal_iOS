import UIKit
import SwiftUI

// MARK: - View
protocol FAQViewable: AnyObject {
}

// MARK: - ViewModel
typealias FAQViewModelProtocol = FAQViewModelLifeCycle
    & FAQViewInteraction
    & FAQViewState

protocol FAQViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

protocol FAQViewInteraction: AnyObject {
    func handleActionEvent(_ event: FAQViewActionEvent)
}

protocol FAQViewState: AnyObject, ObservableObject {
    var faqItems: [FAQViewItem] { get set }
    var footerText: LocalizedStringKey { get }
}

// MARK: - Model

// sourcery: AutoMockable
protocol FAQModelProtocol: AnyObject {
    func fetchQuestions() async throws -> [FAQModel.Question]
}

// MARK: - Actions
enum FAQViewActionEvent {
    case back
    case toggleItem(_ id: FAQViewItem.ID)
}
