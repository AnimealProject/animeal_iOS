// swiftlint:disable all
import Amplify
import Foundation

public struct Category: Model {
  public let id: String
  public var name: String
  public var icon: String
  public var tag: CategoryTag
  public var i18n: [CategoryI18n]?
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime
  public var createdBy: String?
  public var updatedBy: String?
  public var owner: String?
  
  public init(id: String = UUID().uuidString,
      name: String,
      icon: String,
      tag: CategoryTag,
      i18n: [CategoryI18n]? = nil,
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime,
      createdBy: String? = nil,
      updatedBy: String? = nil,
      owner: String? = nil) {
      self.id = id
      self.name = name
      self.icon = icon
      self.tag = tag
      self.i18n = i18n
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.createdBy = createdBy
      self.updatedBy = updatedBy
      self.owner = owner
  }
}