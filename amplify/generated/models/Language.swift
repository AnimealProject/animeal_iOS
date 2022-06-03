// swiftlint:disable all
import Amplify
import Foundation

public struct Language: Model {
  public let id: String
  public var name: String
  public var code: String
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime
  public var createdBy: String?
  public var updatedBy: String?
  public var direction: String
  
  public init(id: String = UUID().uuidString,
      name: String,
      code: String,
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime,
      createdBy: String? = nil,
      updatedBy: String? = nil,
      direction: String) {
      self.id = id
      self.name = name
      self.code = code
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.createdBy = createdBy
      self.updatedBy = updatedBy
      self.direction = direction
  }
}