// swiftlint:disable all
import Amplify
import Foundation

public struct FeedingPointI18n: Embeddable {
  var locale: String
  var name: String?
  var description: String?
  var city: String?
  var street: String?
  var address: String?
  var region: String?
  var neighborhood: String?
}