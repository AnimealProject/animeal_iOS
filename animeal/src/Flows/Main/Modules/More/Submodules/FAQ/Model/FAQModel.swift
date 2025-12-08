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
