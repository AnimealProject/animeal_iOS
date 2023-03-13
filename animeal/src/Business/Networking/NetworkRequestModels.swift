import Foundation

// MARK: - Custom StartFeeding mutation

public struct StartFeedingMutation: CustomMutation {
    public typealias ResponseType = StartFeeding

    let id: String

    public var document: String {
        """
        mutation StartFeeding {
            startFeeding(feedingPointId: "\(id)")
        }
        """
    }
}

public struct StartFeeding: Codable {
    let startFeeding: String
}

// MARK: - Custom CancelFeeding mutation

public struct CancelFeedingMutation: CustomMutation {
    public typealias ResponseType = CancelFeeding

    static let defaultCancelationReason = "User cancel the request"

    let id: String
    let reason: String

    init(
        id: String,
        reason: String = Self.defaultCancelationReason
    ) {
        self.id = id
        self.reason = reason
    }

    public var document: String {
        """
        mutation StopFeeding {
            cancelFeeding(feedingId: "\(id)", reason: "\(reason)")
        }
        """
    }
}

public struct RejectFeedingMutation: CustomMutation {
    public typealias ResponseType = RejectFeeding

    static let defaultRejectReason = "Feeding time has expired"

    let id: String
    let reason: String
    let feeding: Feeding

    init(
        id: String,
        reason: String = Self.defaultRejectReason,
        feeding: Feeding
    ) {
        self.id = id
        self.reason = reason
        self.feeding = feeding
    }

    public var document: String {
        """
        mutation RejectFeeding {
            rejectFeeding(
                feedingId: "\(id)",
                reason: "\(reason)",
                feeding: {
                    createdAt: "\(feeding.createdAt.iso8601String)",
                    feedingPointFeedingsId: "\(feeding.id)",
                    createdBy: "\(feeding.createdBy.orNull)",
                    id: "\(feeding.id)",
                    images: "\(feeding.images)",
                    owner: "\(feeding.owner.orNull)",
                    updatedAt: "\(feeding.updatedAt.iso8601String)",
                    updatedBy: "\(feeding.updatedBy.orNull)",
                    userId: "\(feeding.userId)"
                }
            )
        }
        """
    }
}

public struct CancelFeeding: Codable {
    let cancelFeeding: String
}

public struct RejectFeeding: Codable {
    let rejectFeeding: String
}

// MARK: - UpdateFeedingPoint

struct UpdateFeedingPoint: Codable {
    let id: String
}

// MARK: - Custom FinishFeeding mutation

public struct FinishFeedingMutation: CustomMutation {
    public typealias ResponseType = FinishFeeding

    let id: String
    let images: [String]

    public var document: String {
        """
        mutation FinishFeeding {
            finishFeeding(feedingId: "\(id)", images: [\(imagesList)])
        }
        """
    }

    private var imagesList: String {
        images.map { "\"\($0)\"" }.joined(separator: ",")
    }
}

public struct FinishFeeding: Codable {
    let finishFeeding: String
}

private extension String {
    static var null: String {
        return "null"
    }
}

private extension Optional where Wrapped: StringProtocol {
    var orNull: String {
        String.null
    }
}
