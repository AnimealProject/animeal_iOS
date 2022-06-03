// swiftlint:disable all
import Amplify
import Foundation

public struct RelationUserPet: Model {
  public let id: String
  public var userId: String
  public var pet: Pet
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userId: String,
      pet: Pet) {
    self.init(id: id,
      userId: userId,
      pet: pet,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      userId: String,
      pet: Pet,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userId = userId
      self.pet = pet
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}