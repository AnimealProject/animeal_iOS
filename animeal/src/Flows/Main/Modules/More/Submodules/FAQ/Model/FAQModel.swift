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
            .filter { $0.orderNum != nil }
            .sorted(by: { $0.orderNum! < $1.orderNum! })
        let unordered = questions.filter { $0.orderNum == nil }
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
