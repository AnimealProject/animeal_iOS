import Foundation
import Services

final class FeedingPointDetailsModel: FeedingPointDetailsModelProtocol {
    // MARK: - Private properties
    private let pointId: String
    private let mapper: FeedingPointDetailsModelMapperProtocol

    typealias Context = NetworkServiceHolder
    private let context: Context

    // MARK: - Initialization
    init(
        pointId: String,
        mapper: FeedingPointDetailsModelMapperProtocol = FeedingPointDetailsModelMapper(),
        context: Context = AppDelegate.shared.context
    ) {
        self.pointId = pointId
        self.mapper = mapper
        self.context = context
    }

    func fetchFeedingPoints(_ completion: ((FeedingPointDetailsModel.PointContent) -> Void)?) {
        context.networkService.query(request: .get(FeedingPoint.self, byId: pointId)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let point):
                guard let point = point else {
                    return
                }
                DispatchQueue.main.async {
                    completion?(self.mapper.map(point))
                }
            case .failure(let error):
                // TODO: Handele error
                print(error)
            }
        }
    }

    func fetchFeedingPoints() async throws -> FeedingPointDetailsModel.PointContent {
        try await withCheckedThrowingContinuation { continuation in
            fetchFeedingPoints {
                continuation.resume(with: .success($0))
            }
        }
    }
}

extension FeedingPointDetailsModel {
    struct PointContent {
        let content: Content
        let action: Action
    }

    struct Content {
        let header: Header
        let description: Description
        let status: Status
        let feeders: [Feeder]
    }

    struct Feeder {
        let name: String
        let lastFeeded: String
    }

    struct Header {
        let title: String
    }

    struct Description {
        let text: String
    }

    struct Action {
        let identifier: String
        let title: String
    }

    enum Status {
        case success(String)
        case attention(String)
        case error(String)
    }
}
