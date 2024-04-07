// swiftlint:disable all
import Amplify
import Foundation

extension FeedingPointI18n {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case locale
    case name
    case description
    case city
    case street
    case address
    case region
    case neighborhood
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let feedingPointI18n = FeedingPointI18n.keys
    
    model.listPluralName = "FeedingPointI18ns"
    model.syncPluralName = "FeedingPointI18ns"
    
    model.fields(
      .field(feedingPointI18n.locale, is: .required, ofType: .string),
      .field(feedingPointI18n.name, is: .optional, ofType: .string),
      .field(feedingPointI18n.description, is: .optional, ofType: .string),
      .field(feedingPointI18n.city, is: .optional, ofType: .string),
      .field(feedingPointI18n.street, is: .optional, ofType: .string),
      .field(feedingPointI18n.address, is: .optional, ofType: .string),
      .field(feedingPointI18n.region, is: .optional, ofType: .string),
      .field(feedingPointI18n.neighborhood, is: .optional, ofType: .string)
    )
    }
}