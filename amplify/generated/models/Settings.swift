// swiftlint:disable all
import Amplify
import Foundation

public struct Settings: Model {
  public let id: String
  public var key: String
  public var value: String
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      key: String,
      value: String) {
    self.init(id: id,
      key: key,
      value: value,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      key: String,
      value: String,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.key = key
      self.value = value
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}