// swiftlint:disable all
import Amplify
import Foundation

public struct QuestionI18n: Embeddable {
  var locale: String
  var value: String?
  var answer: String?
}