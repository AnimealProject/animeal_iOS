// swiftlint:disable all
import Amplify
import Foundation

public enum FeedingStatus: String, EnumPersistable {
  case approved
  case rejected
  case pending
  case inProgress
  case outdated
}