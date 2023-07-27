// swiftlint:disable all
import Amplify
import Foundation

extension UserAttribute {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case Name
    case Value
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let userAttribute = UserAttribute.keys
    
    model.pluralName = "UserAttributes"
    
    model.fields(
      .field(userAttribute.Name, is: .required, ofType: .string),
      .field(userAttribute.Value, is: .optional, ofType: .string)
    )
    }
}