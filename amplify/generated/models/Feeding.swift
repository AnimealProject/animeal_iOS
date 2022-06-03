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
  public var feedingPoint: FeedingPoint
  
  public init(id: String = UUID().uuidString,
      userId: String,
      images: [String] = [],
      status: FeedingStatus,
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime,
      createdBy: String? = nil,
      updatedBy: String? = nil,
      owner: String? = nil,
      feedingPoint: FeedingPoint) {
      self.id = id
      self.userId = userId
      self.images = images
      self.status = status
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.createdBy = createdBy
      self.updatedBy = updatedBy
      self.owner = owner
      self.feedingPoint = feedingPoint
  }
}