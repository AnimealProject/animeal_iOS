import Foundation
import Style
import UIComponents

// sourcery: AutoMockable
protocol QuestionViewMappable {
    func mapQuestion(_ input: FAQModel.Question) -> FAQViewItem
}

final class QuestionViewMapper: QuestionViewMappable {
    func mapQuestion(_ input: FAQModel.Question) -> FAQViewItem {
        FAQViewItem(
            id: input.id,
            question: input.question,
            answer: input.answer,
            collapsed: true
        )
    }
}

struct FAQViewItem: Identifiable {
    let id: String
    let question: String
    let answer: String
    let collapsed: Bool
}
