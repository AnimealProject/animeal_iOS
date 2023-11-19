// swiftlint:disable all
import Amplify
import Foundation

extension CategoryI18n {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case locale
    case name
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let categoryI18n = CategoryI18n.keys
    
    model.listPluralName = "CategoryI18ns"
    model.syncPluralName = "CategoryI18ns"
    
    model.fields(
      .field(categoryI18n.locale, is: .required, ofType: .string),
      .field(categoryI18n.name, is: .optional, ofType: .string)
    )
    }
}