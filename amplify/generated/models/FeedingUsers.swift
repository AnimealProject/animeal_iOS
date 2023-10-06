// swiftlint:disable all
import Amplify
import Foundation

public struct FeedingUsers: Model {
  public let id: String
  public var attributes: [UserAttribute?]?
  public var createdAt: String?
  public var updatedAt: String?
  public var owner: String?
  
  public init(id: String = UUID().uuidString,
      attributes: [UserAttribute?]? = nil,
      createdAt: String? = nil,
      updatedAt: String? = nil,
      owner: String? = nil) {
      self.id = id
      self.attributes = attributes
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.owner = owner
  }
}