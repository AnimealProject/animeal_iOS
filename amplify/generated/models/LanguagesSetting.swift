// swiftlint:disable all
import Amplify
import Foundation

public struct LanguagesSetting: Model {
  public let id: String
  public var name: String
  public var value: String
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime
  public var createdBy: String?
  public var updatedBy: String?
  
  public init(id: String = UUID().uuidString,
      name: String,
      value: String,
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime,
      createdBy: String? = nil,
      updatedBy: String? = nil) {
      self.id = id
      self.name = name
      self.value = value
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.createdBy = createdBy
      self.updatedBy = updatedBy
  }
}