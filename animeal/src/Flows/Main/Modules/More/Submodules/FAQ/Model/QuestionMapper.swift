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
        switch Locale.current.languageCode {
        case "ka":
            return value ?? .empty
        default:
            return i18n?.first(where: { $0.locale == "en" })?.value ?? .empty
        }
    }

    var localizedAnswer: String {
        switch Locale.current.languageCode {
        case "ka":
            return answer ?? .empty
        default:
            return i18n?.first(where: { $0.locale == "en" })?.answer ?? .empty
        }
    }
}
