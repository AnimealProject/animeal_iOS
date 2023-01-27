// swiftlint:disable all
import Amplify
import Foundation

public struct BankAccount: Model {
  public let id: String
  public var name: String
  public var value: String
  public var cover: String
  public var images: [String]?
  public var enabled: Bool
  public var createdBy: String?
  public var updatedBy: String?
  public var owner: String?
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime
  
  public init(id: String = UUID().uuidString,
      name: String,
      value: String,
      cover: String,
      images: [String]? = nil,
      enabled: Bool,
      createdBy: String? = nil,
      updatedBy: String? = nil,
      owner: String? = nil,
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime) {
      self.id = id
      self.name = name
      self.value = value
      self.cover = cover
      self.images = images
      self.enabled = enabled
      self.createdBy = createdBy
      self.updatedBy = updatedBy
      self.owner = owner
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}