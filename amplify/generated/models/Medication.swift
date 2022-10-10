// swiftlint:disable all
import Amplify
import Foundation

public struct Medication: Model {
  public let id: String
  public var name: String
  public var pet: Pet
  public var date: Temporal.DateTime
  public var i18n: [MedicationI18n]?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      name: String,
      pet: Pet,
      date: Temporal.DateTime,
      i18n: [MedicationI18n]? = nil) {
    self.init(id: id,
      name: name,
      pet: pet,
      date: date,
      i18n: i18n,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      name: String,
      pet: Pet,
      date: Temporal.DateTime,
      i18n: [MedicationI18n]? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.name = name
      self.pet = pet
      self.date = date
      self.i18n = i18n
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}