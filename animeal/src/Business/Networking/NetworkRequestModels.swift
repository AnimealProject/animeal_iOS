import Foundation

// MARK: - SearchByBounds

/// Bounding box passed to the searchByBounds GraphQL query.
/// top_left is NW corner, bottom_right is SE corner.
struct BoundsInput {
    let topLeftLat: Double
    let topLeftLon: Double
    let bottomRightLat: Double
    let bottomRightLon: Double

    var variables: [String: Any] {
        [
            "top_left": ["lat": topLeftLat, "lon": topLeftLon],
            "bottom_right": ["lat": bottomRightLat, "lon": bottomRightLon]
        ]
    }
}

let searchByBoundsDocument = """
query SearchByBounds($bounds: BoundsInput!, $limit: Int) {
  searchByBounds(bounds: $bounds, limit: $limit) {
    items {
      id
      name
      description
      city
      street
      address
      images
      point {
        type
        coordinates
      }
      location {
        lat
        lon
      }
      region
      neighborhood
      distance
      status
      i18n {
        locale
        name
        description
        city
        street
        address
        region
        neighborhood
      }
      statusUpdatedAt
      createdAt
      updatedAt
      createdBy
      updatedBy
      owner
      cover
      disabled
      feedingPointCategoryId
    }
  }
}
"""

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

public struct CancelFeeding: Codable {
    let cancelFeeding: String
}

// MARK: - Custom Expration mutation

public struct ExpireFeedingMutation: CustomMutation {
    public typealias ResponseType = ExpireFeeding

    static let defaultExpirationReason = "Feeding time has expired"

    let id: String
    let reason: String

    init(
        id: String,
        reason: String = Self.defaultExpirationReason
    ) {
        self.id = id
        self.reason = reason
    }

    public var document: String {
        """
        mutation ExpireFeeding {
           expireFeeding(feedingId: "\(id)", reason: "\(reason)")
        }
        """
    }
}

public struct ExpireFeeding: Codable {
    let expireFeeding: String
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
