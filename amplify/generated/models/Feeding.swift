// swiftlint:disable all
import Amplify
import Foundation

public struct Feeding: Model {
  public let id: String
  public var userId: String
  public var images: [String]
  public var status: FeedingStatus
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime
  public var createdBy: String?
  public var updatedBy: String?
  public var owner: String?
  public var feedingPointDetails: FeedingPointDetails?
  public var feedingPointFeedingsId: String
  public var expireAt: Int
  public var assignedModerators: [String?]?
  public var moderatedBy: String?
  public var moderatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userId: String,
      images: [String] = [],
      status: FeedingStatus,
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime,
      createdBy: String? = nil,
      updatedBy: String? = nil,
      owner: String? = nil,
      feedingPointDetails: FeedingPointDetails? = nil,
      feedingPointFeedingsId: String,
      expireAt: Int,
      assignedModerators: [String?]? = nil,
      moderatedBy: String? = nil,
      moderatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userId = userId
      self.images = images
      self.status = status
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.createdBy = createdBy
      self.updatedBy = updatedBy
      self.owner = owner
      self.feedingPointDetails = feedingPointDetails
      self.feedingPointFeedingsId = feedingPointFeedingsId
      self.expireAt = expireAt
      self.assignedModerators = assignedModerators
      self.moderatedBy = moderatedBy
      self.moderatedAt = moderatedAt
  }
}