// swiftlint:disable all
import Amplify
import Foundation

public struct FeedingUsers: Model {
  public let id: String
  public var attributes: [UserAttribute?]?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      attributes: [UserAttribute?]? = nil) {
    self.init(id: id,
      attributes: attributes,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      attributes: [UserAttribute?]? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.attributes = attributes
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}