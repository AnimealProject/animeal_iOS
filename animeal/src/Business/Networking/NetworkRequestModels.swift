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

    let id: String

    public var document: String {
        """
        mutation StopFeeding {
            cancelFeeding(feedingId: "\(id)")
        }
        """
    }
}

public struct CancelFeeding: Codable {
    let cancelFeeding: String
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
