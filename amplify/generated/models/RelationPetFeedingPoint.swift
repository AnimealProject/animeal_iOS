// swiftlint:disable all
import Amplify
import Foundation

public struct RelationPetFeedingPoint: Model {
  public let id: String
  public var pet: Pet
  public var feedingPoint: FeedingPoint
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime
  public var owner: String?
  
  public init(id: String = UUID().uuidString,
      pet: Pet,
      feedingPoint: FeedingPoint,
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime,
      owner: String? = nil) {
      self.id = id
      self.pet = pet
      self.feedingPoint = feedingPoint
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.owner = owner
  }
}