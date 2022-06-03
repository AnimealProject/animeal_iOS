// swiftlint:disable all
import Amplify
import Foundation

public struct Pet: Model {
  public let id: String
  public var name: String
  public var images: [String]
  public var breed: String
  public var color: String
  public var age: Int
  public var chipNumber: String
  public var vaccinatedAt: Temporal.DateTime
  public var caretaker: Caretaker?
  public var i18n: [PetI18n]?
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime
  public var createdBy: String?
  public var updatedBy: String?
  public var owner: String?
  public var feedingPoints: List<RelationPetFeedingPoint>?
  public var category: Category
  public var medications: List<Medication>?
  public var users: List<RelationUserPet>?
  public var petCategoryId: String
  
  public init(id: String = UUID().uuidString,
      name: String,
      images: [String] = [],
      breed: String,
      color: String,
      age: Int,
      chipNumber: String,
      vaccinatedAt: Temporal.DateTime,
      caretaker: Caretaker? = nil,
      i18n: [PetI18n]? = nil,
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime,
      createdBy: String? = nil,
      updatedBy: String? = nil,
      owner: String? = nil,
      feedingPoints: List<RelationPetFeedingPoint> = [],
      category: Category,
      medications: List<Medication> = [],
      users: List<RelationUserPet> = [],
      petCategoryId: String) {
      self.id = id
      self.name = name
      self.images = images
      self.breed = breed
      self.color = color
      self.age = age
      self.chipNumber = chipNumber
      self.vaccinatedAt = vaccinatedAt
      self.caretaker = caretaker
      self.i18n = i18n
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.createdBy = createdBy
      self.updatedBy = updatedBy
      self.owner = owner
      self.feedingPoints = feedingPoints
      self.category = category
      self.medications = medications
      self.users = users
      self.petCategoryId = petCategoryId
  }
}