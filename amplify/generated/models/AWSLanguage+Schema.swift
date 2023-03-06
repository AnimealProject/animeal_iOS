// swiftlint:disable all
import Amplify
import Foundation

extension AWSLanguage {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case code
    case name
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let aWSLanguage = AWSLanguage.keys
    
    model.pluralName = "AWSLanguages"
    
    model.fields(
      .field(aWSLanguage.code, is: .optional, ofType: .string),
      .field(aWSLanguage.name, is: .optional, ofType: .string)
    )
    }
}