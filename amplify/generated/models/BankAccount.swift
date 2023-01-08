// swiftlint:disable all
import Amplify
import Foundation

public struct BankAccount: Model {
  public let id: String
  public var name: String
  public var value: String
  public var icon: String
  public var enabled: Bool
  public var createdBy: String?
  public var updatedBy: String?
  public var owner: String?
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime
  
  public init(id: String = UUID().uuidString,
      name: String,
      value: String,
      icon: String,
      enabled: Bool,
      createdBy: String? = nil,
      updatedBy: String? = nil,
      owner: String? = nil,
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime) {
      self.id = id
      self.name = name
      self.value = value
      self.icon = icon
      self.enabled = enabled
      self.createdBy = createdBy
      self.updatedBy = updatedBy
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}