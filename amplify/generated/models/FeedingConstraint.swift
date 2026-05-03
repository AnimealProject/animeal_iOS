// swiftlint:disable all
import Amplify
import Foundation

public struct FeedingConstraint: Model {
  public let id: String
  public var feedingHistoryId: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?

  public init(id: String = UUID().uuidString,
      feedingHistoryId: String? = nil) {
    self.init(id: id,
      feedingHistoryId: feedingHistoryId,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      feedingHistoryId: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.feedingHistoryId = feedingHistoryId
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}
