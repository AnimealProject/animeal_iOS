// swiftlint:disable all
import Amplify
import Foundation

extension Caretaker {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case fullName
    case email
    case phoneNumber
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let caretaker = Caretaker.keys
    
    model.listPluralName = "Caretakers"
    model.syncPluralName = "Caretakers"
    
    model.fields(
      .field(caretaker.fullName, is: .optional, ofType: .string),
      .field(caretaker.email, is: .optional, ofType: .string),
      .field(caretaker.phoneNumber, is: .optional, ofType: .string)
    )
    }
}