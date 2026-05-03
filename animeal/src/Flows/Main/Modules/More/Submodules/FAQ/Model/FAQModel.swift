import Foundation
import Services

final class FAQModel: FAQModelProtocol {
    // MARK: - Private properties
    private let networkService: NetworkServiceProtocol
    private let mapper: QuestionMappable

    // MARK: - Initialization
    init(
        networkService: NetworkServiceProtocol = AdaptiveNetworkService(),
        mapper: QuestionMappable = QuestionMapper()
    ) {
        self.networkService = networkService
        self.mapper = mapper
    }

    func fetchQuestions() async throws -> [Question] {
        let questions = try await networkService.query(request: .list(animeal.Question.self))
        let ordered = orderQuestions(questions)
        return ordered.map(mapper.mapQuestion)
    }

    private func orderQuestions(_ questions: [animeal.Question]) -> [animeal.Question] {
        let ordered = questions
            .compactMap { question -> (animeal.Question, Int)? in
                guard let orderNumber = question.orderNum else { return nil }
                return (question, orderNumber)
            }
            .sorted { $0.1 < $1.1 }
            .map { $0.0 }
        let unordered = questions.filter { $0.orderNum == nil }
            .compactMap { question -> (animeal.Question, String)? in
                guard let questionValue = question.value else { return nil }
                return (question, questionValue)
            }
            .sorted { $0.1.localizedStandardCompare($1.1) == .orderedAscending }
            .map { $0.0 }
        return ordered + unordered
    }
}

extension FAQModel {
    struct Question {
        let id: String
        let question: String
        let answer: String
    }
}
