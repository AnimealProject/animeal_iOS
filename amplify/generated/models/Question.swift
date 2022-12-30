// swiftlint:disable all
import Amplify
import Foundation

public struct Question: Model {
  public let id: String
  public var value: String?
  public var answer: String?
  public var i18n: [QuestionI18n]?
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime
  public var createdBy: String?
  public var updatedBy: String?
  
  public init(id: String = UUID().uuidString,
      value: String? = nil,
      answer: String? = nil,
      i18n: [QuestionI18n]? = nil,
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime,
      createdBy: String? = nil,
      updatedBy: String? = nil) {
      self.id = id
      self.value = value
      self.answer = answer
      self.i18n = i18n
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.createdBy = createdBy
      self.updatedBy = updatedBy
  }
}