// swiftlint:disable all
import Amplify
import Foundation

public struct BankAccount: Model {
  public let id: String
  public var name: String
  public var value: String
  public var icon: String
  public var enabled: Bool
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      name: String,
      value: String,
      icon: String,
      enabled: Bool) {
    self.init(id: id,
      name: name,
      value: value,
      icon: icon,
      enabled: enabled,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      name: String,
      value: String,
      icon: String,
      enabled: Bool,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.name = name
      self.value = value
      self.icon = icon
      self.enabled = enabled
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}