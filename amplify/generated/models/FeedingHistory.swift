// swiftlint:disable all
import Amplify
import Foundation

public struct FeedingHistory: Model {
  public let id: String
  public var userId: String
  public var images: [String]
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime
  public var createdBy: String?
  public var updatedBy: String?
  public var owner: String?
  public var feedingPointId: String
  public var feedingPointDetails: FeedingPointDetails?
  public var status: FeedingStatus?
  public var reason: String?
  public var moderatedBy: String?
  public var moderatedAt: Temporal.DateTime?
  public var assignedModerators: [String?]?
  
  public init(id: String = UUID().uuidString,
      userId: String,
      images: [String] = [],
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime,
      createdBy: String? = nil,
      updatedBy: String? = nil,
      owner: String? = nil,
      feedingPointId: String,
      feedingPointDetails: FeedingPointDetails? = nil,
      status: FeedingStatus? = nil,
      reason: String? = nil,
      moderatedBy: String? = nil,
      moderatedAt: Temporal.DateTime? = nil,
      assignedModerators: [String?]? = nil) {
      self.id = id
      self.userId = userId
      self.images = images
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.createdBy = createdBy
      self.updatedBy = updatedBy
      self.owner = owner
      self.feedingPointId = feedingPointId
      self.feedingPointDetails = feedingPointDetails
      self.status = status
      self.reason = reason
      self.moderatedBy = moderatedBy
      self.moderatedAt = moderatedAt
      self.assignedModerators = assignedModerators
  }
}