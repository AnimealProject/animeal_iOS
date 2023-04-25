// swiftlint:disable all
import Amplify
import Foundation

public struct Favourite: Model {
  public let id: String
  public var userId: String
  public var feedingPointId: String
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userId: String,
      feedingPointId: String) {
    self.init(id: id,
      userId: userId,
      feedingPointId: feedingPointId,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      userId: String,
      feedingPointId: String,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userId = userId
      self.feedingPointId = feedingPointId
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}