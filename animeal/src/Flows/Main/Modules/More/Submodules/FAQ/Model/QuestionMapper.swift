import Foundation

// sourcery: AutoMockable
protocol QuestionMappable {
    func mapQuestion(_ input: animeal.Question) -> FAQModel.Question
}

final class QuestionMapper: QuestionMappable {
    func mapQuestion(_ input: animeal.Question) -> FAQModel.Question {
        FAQModel.Question(
            id: input.id,
            question: input.localizedValue,
            answer: input.localizedAnswer
        )
    }
}

private extension Question {
    var localizedValue: String {
        localized?.value ?? value ?? .empty
    }

    var localizedAnswer: String {
        localized?.answer ?? answer ?? .empty
    }

    private var localized: QuestionI18n? {
        i18n?.first { $0.locale == Locale.current.languageCode }
    }
}
