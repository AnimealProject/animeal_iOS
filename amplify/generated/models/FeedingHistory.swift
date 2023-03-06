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
  public var status: FeedingStatus?
  public var reason: String?
  
  public init(id: String = UUID().uuidString,
      userId: String,
      images: [String] = [],
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime,
      createdBy: String? = nil,
      updatedBy: String? = nil,
      owner: String? = nil,
      feedingPointId: String,
      status: FeedingStatus? = nil,
      reason: String? = nil) {
      self.id = id
      self.userId = userId
      self.images = images
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.createdBy = createdBy
      self.updatedBy = updatedBy
      self.owner = owner
      self.feedingPointId = feedingPointId
      self.status = status
      self.reason = reason
  }
}