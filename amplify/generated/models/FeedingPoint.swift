// swiftlint:disable all
import Amplify
import Foundation

public struct FeedingPoint: Model {
  public let id: String
  public var name: String
  public var description: String
  public var city: String
  public var street: String
  public var address: String
  public var images: [String]?
  public var point: Point
  public var location: Location
  public var region: String
  public var neighborhood: String
  public var distance: Double
  public var status: FeedingPointStatus
  public var i18n: [FeedingPointI18n]?
  public var statusUpdatedAt: Temporal.DateTime
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime
  public var createdBy: String?
  public var updatedBy: String?
  public var owner: String?
  public var pets: List<RelationPetFeedingPoint>?
  public var category: Category?
  public var users: List<RelationUserFeedingPoint>?
  public var cover: String?
  public var feedingPointCategoryId: String?
  
  public init(id: String = UUID().uuidString,
      name: String,
      description: String,
      city: String,
      street: String,
      address: String,
      images: [String]? = nil,
      point: Point,
      location: Location,
      region: String,
      neighborhood: String,
      distance: Double,
      status: FeedingPointStatus,
      i18n: [FeedingPointI18n]? = nil,
      statusUpdatedAt: Temporal.DateTime,
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime,
      createdBy: String? = nil,
      updatedBy: String? = nil,
      owner: String? = nil,
      pets: List<RelationPetFeedingPoint> = [],
      category: Category? = nil,
      users: List<RelationUserFeedingPoint> = [],
      cover: String? = nil,
      feedingPointCategoryId: String? = nil) {
      self.id = id
      self.name = name
      self.description = description
      self.city = city
      self.street = street
      self.address = address
      self.images = images
      self.point = point
      self.location = location
      self.region = region
      self.neighborhood = neighborhood
      self.distance = distance
      self.status = status
      self.i18n = i18n
      self.statusUpdatedAt = statusUpdatedAt
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.createdBy = createdBy
      self.updatedBy = updatedBy
      self.owner = owner
      self.pets = pets
      self.category = category
      self.users = users
      self.cover = cover
      self.feedingPointCategoryId = feedingPointCategoryId
  }
}