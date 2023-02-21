import Foundation
import Services

final class FAQModel: FAQModelProtocol {
    typealias Context = DefaultsServiceHolder & NetworkServiceHolder

    // MARK: - Private properties
    private let context: Context
    private let mapper: QuestionMappable

    // MARK: - Initialization
    init(context: Context = AppDelegate.shared.context,
         mapper: QuestionMappable = QuestionMapper()) {
        self.context = context
        self.mapper = mapper
    }
    
    func fetchQuestions() async throws -> [Question] {
        let questions = try await context.networkService.query(request: .list(animeal.Question.self))
        return questions.map(mapper.mapQuestion)
    }
}

extension FAQModel {
    struct Question {
        let id: String
        let question: String
        let answer: String
    }
}
