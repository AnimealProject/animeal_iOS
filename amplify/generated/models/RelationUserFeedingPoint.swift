// swiftlint:disable all
import Amplify
import Foundation

public struct RelationUserFeedingPoint: Model {
  public let id: String
  public var userId: String
  public var feedingPoint: FeedingPoint
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userId: String,
      feedingPoint: FeedingPoint) {
    self.init(id: id,
      userId: userId,
      feedingPoint: feedingPoint,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      userId: String,
      feedingPoint: FeedingPoint,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userId = userId
      self.feedingPoint = feedingPoint
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}