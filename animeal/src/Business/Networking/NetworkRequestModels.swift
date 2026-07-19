import Foundation

// MARK: - Location bounds input

/// Bounding box used by getFeedingPoints and searchByBounds queries.
/// top_left is NW corner, bottom_right is SE corner.
struct BoundsInput: Equatable {
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

    func contains(_ other: BoundsInput) -> Bool {
        other.topLeftLat <= topLeftLat &&
        other.topLeftLon >= topLeftLon &&
        other.bottomRightLat >= bottomRightLat &&
        other.bottomRightLon <= bottomRightLon
    }

    func clamped(minimumRadius: Double) -> BoundsInput {
        let latCenter = (topLeftLat + bottomRightLat) / 2
        let lonCenter = (topLeftLon + bottomRightLon) / 2
        let latHalf = max((topLeftLat - bottomRightLat) / 2, minimumRadius)
        let lonHalf = max((bottomRightLon - topLeftLon) / 2, minimumRadius)
        return BoundsInput(
            topLeftLat: latCenter + latHalf,
            topLeftLon: lonCenter - lonHalf,
            bottomRightLat: latCenter - latHalf,
            bottomRightLon: lonCenter + lonHalf
        )
    }

    func expanded(by factor: Double) -> BoundsInput {
        let latBuffer = (topLeftLat - bottomRightLat) * (factor - 1) / 2
        let lonBuffer = (bottomRightLon - topLeftLon) * (factor - 1) / 2
        return BoundsInput(
            topLeftLat: topLeftLat + latBuffer,
            topLeftLon: topLeftLon - lonBuffer,
            bottomRightLat: bottomRightLat - latBuffer,
            bottomRightLon: bottomRightLon + lonBuffer
        )
    }

    /// Bounding box covering all of Georgia (incl. Tbilisi and Batumi).
    /// Used by `FeatureFlags.isLoadAllFeedingPointsEnabled` to fetch every feeding point upfront.
    static let allGeorgia = BoundsInput(
        topLeftLat: 43.6,
        topLeftLon: 39.9,
        bottomRightLat: 41.0,
        bottomRightLon: 46.8
    )
}

// MARK: - GetFeedingPoints query

let getFeedingPointsDocument = """
query GetFeedingPoints($locationBounds: BoundsInput, $categoryTag: String) {
  getFeedingPoints(locationBounds: $locationBounds, categoryTag: $categoryTag) {
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
    category {
      id
      name
      icon
      tag
      createdAt
      updatedAt
      createdBy
      updatedBy
      owner
    }
  }
}
"""

// MARK: - GetActiveFeedings query

let getActiveFeedingsDocument = """
query GetActiveFeedings($feedingPointId: String, $status: String) {
  getActiveFeedings(feedingPointId: $feedingPointId, status: $status) {
    id
    userId
    images
    status
    createdAt
    updatedAt
    createdBy
    updatedBy
    owner
    feedingPointDetails {
      address
    }
    feedingPointFeedingsId
    expireAt
    assignedModerators
    moderatedBy
    moderatedAt
  }
}
"""

// MARK: - GetHistoricalFeedings query

let getHistoricalFeedingsDocument = """
query GetHistoricalFeedings($feedingPointId: String, $status: String) {
  getHistoricalFeedings(feedingPointId: $feedingPointId, status: $status) {
    id
    userId
    images
    createdAt
    updatedAt
    createdBy
    updatedBy
    owner
    feedingPointId
    feedingPointDetails {
      address
    }
    status
    reason
    moderatedBy
    moderatedAt
    assignedModerators
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

// MARK: - Feeding Management

public struct RejectFeedingMutation: CustomMutation {
    public typealias ResponseType = RejectFeeding

    let feedingId: String
    let reason: String

    public var document: String {
        """
        mutation RejectFeeding {
            rejectFeeding(feedingId: "\(feedingId)", reason: "\(reason)")
        }
        """
    }
}

public struct RejectFeeding: Codable {
    let rejectFeeding: String
}

public struct ApproveFeedingMutation: CustomMutation {
    public typealias ResponseType = ApproveFeeding

    let feedingId: String
    let reason: String

    public var document: String {
        """
        mutation ApproveFeeding {
            approveFeeding(feedingId: "\(feedingId)", reason: "\(reason)")
        }
        """
    }
}

public struct ApproveFeeding: Codable {
    let approveFeeding: String
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
