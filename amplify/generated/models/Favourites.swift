// swiftlint:disable all
import Amplify
import Foundation

public struct Favourites: Model {
  public let id: String
  public var userId: String
  public var feedingPointId: String
  public var feedingPoint: FeedingPoint
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userId: String,
      feedingPointId: String,
      feedingPoint: FeedingPoint) {
    self.init(id: id,
      userId: userId,
      feedingPointId: feedingPointId,
      feedingPoint: feedingPoint,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      userId: String,
      feedingPointId: String,
      feedingPoint: FeedingPoint,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userId = userId
      self.feedingPointId = feedingPointId
      self.feedingPoint = feedingPoint
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}