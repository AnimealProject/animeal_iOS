// swiftlint:disable all
import Amplify
import Foundation

extension PetI18n {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case locale
    case name
    case breed
    case color
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let petI18n = PetI18n.keys
    
    model.listPluralName = "PetI18ns"
    model.syncPluralName = "PetI18ns"
    
    model.fields(
      .field(petI18n.locale, is: .required, ofType: .string),
      .field(petI18n.name, is: .optional, ofType: .string),
      .field(petI18n.breed, is: .optional, ofType: .string),
      .field(petI18n.color, is: .optional, ofType: .string)
    )
    }
}