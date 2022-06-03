// swiftlint:disable all
import Amplify
import Foundation

public struct PetI18n: Embeddable {
  var locale: String
  var name: String?
  var breed: String?
  var color: String?
}