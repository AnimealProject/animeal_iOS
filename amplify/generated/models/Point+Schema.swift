// swiftlint:disable all
import Amplify
import Foundation

extension Point {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case type
    case coordinates
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let point = Point.keys
    
    model.listPluralName = "Points"
    model.syncPluralName = "Points"
    
    model.fields(
      .field(point.type, is: .required, ofType: .string),
      .field(point.coordinates, is: .required, ofType: .embeddedCollection(of: Double.self))
    )
    }
}