// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum Action {
    /// Agree
    internal static let agree = L10n.tr("Localizable", "action.agree")
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "action.cancel")
    /// Copy IBAN
    internal static let copyIBAN = L10n.tr("Localizable", "action.copyIBAN")
    /// Delete
    internal static let delete = L10n.tr("Localizable", "action.delete")
    /// Delete Account
    internal static let deleteAccount = L10n.tr("Localizable", "action.deleteAccount")
    /// Finish
    internal static let finish = L10n.tr("Localizable", "action.finish")
    /// Got it
    internal static let gotIt = L10n.tr("Localizable", "action.gotIt")
    /// I will feed
    internal static let iWillFeed = L10n.tr("Localizable", "action.iWillFeed")
    /// Log out
    internal static let logOut = L10n.tr("Localizable", "action.logOut")
    /// No
    internal static let no = L10n.tr("Localizable", "action.no")
    /// Ok
    internal static let ok = L10n.tr("Localizable", "action.ok")
  }

  internal enum Attach {
    internal enum Photo {
      internal enum Hint {
        /// Please take pictures where pet and food is detected
        internal static let text = L10n.tr("Localizable", "attach.photo.hint.text")
      }
    }
  }

  internal enum Errors {
    /// Oops something goes wrong!
    internal static let somthingWrong = L10n.tr("Localizable", "errors.somthingWrong")
  }

  internal enum Favourites {
    /// You don't have favourite feeding points yet. Press the heart button on the feeding point details to add that one as favourite
    internal static let empty = L10n.tr("Localizable", "favourites.empty")
    /// Favourits
    internal static let header = L10n.tr("Localizable", "favourites.header")
  }

  internal enum Feeding {
    internal enum Alert {
      /// Do you really want to cancel feeding?
      internal static let cancelFeeding = L10n.tr("Localizable", "feeding.alert.cancelFeeding")
      /// Another user has booked the feeding for this feeding point
      internal static let feedingPointHasBooked = L10n.tr("Localizable", "feeding.alert.feedingPointHasBooked")
      /// Your feeding timer is over. You can book a new feeding from the home page.
      internal static let feedingTimerOver = L10n.tr("Localizable", "feeding.alert.feedingTimerOver")
    }
    internal enum Status {
      /// Newly fed
      internal static let fed = L10n.tr("Localizable", "feeding.status.fed")
      /// There is no food
      internal static let starved = L10n.tr("Localizable", "feeding.status.starved")
      internal enum Pending {
        /// %s sice not fed
        internal static func pattern(_ p1: UnsafePointer<CChar>) -> String {
          return L10n.tr("Localizable", "feeding.status.pending.pattern", p1)
        }
      }
    }
  }

  internal enum LoginScreen {
    /// Sign in with Apple
    internal static let signInViaApple = L10n.tr("Localizable", "loginScreen.signInViaApple")
    /// Sign in with Facebook
    internal static let signInViaFacebook = L10n.tr("Localizable", "loginScreen.signInViaFacebook")
    /// Sign in with Mobile
    internal static let signInViaMobilePhone = L10n.tr("Localizable", "loginScreen.signInViaMobilePhone")
  }

  internal enum More {
    /// About (terms and conditions)
    internal static let about = L10n.tr("Localizable", "more.about")
    /// About
    internal static let aboutShort = L10n.tr("Localizable", "more.aboutShort")
    /// Account
    internal static let account = L10n.tr("Localizable", "more.account")
    /// Donate
    internal static let donate = L10n.tr("Localizable", "more.donate")
    /// FAQ
    internal static let faq = L10n.tr("Localizable", "more.faq")
    /// Profile Page
    internal static let profilePage = L10n.tr("Localizable", "more.profilePage")
  }

  internal enum Phone {
    /// Please, enter your phone
    internal static let title = L10n.tr("Localizable", "phone.title")
    internal enum Errors {
      /// Required fields are empty
      internal static let empty = L10n.tr("Localizable", "phone.errors.empty")
      /// Format of the phone number isn't correct
      internal static let incorrectPhone = L10n.tr("Localizable", "phone.errors.incorrectPhone")
    }
    internal enum Fields {
      /// Password
      internal static let passwordTitlle = L10n.tr("Localizable", "phone.fields.passwordTitlle")
      /// Phone Number
      internal static let phoneTitlle = L10n.tr("Localizable", "phone.fields.phoneTitlle")
    }
  }

  internal enum Profile {
    /// Birth Date
    internal static let birthDate = L10n.tr("Localizable", "profile.birthDate")
    /// Done
    internal static let done = L10n.tr("Localizable", "profile.done")
    /// Edit
    internal static let edit = L10n.tr("Localizable", "profile.edit")
    /// E-mail
    internal static let email = L10n.tr("Localizable", "profile.email")
    /// Profile
    internal static let header = L10n.tr("Localizable", "profile.header")
    /// Name
    internal static let name = L10n.tr("Localizable", "profile.name")
    /// Phone Number
    internal static let phoneNumber = L10n.tr("Localizable", "profile.phoneNumber")
    /// Save
    internal static let save = L10n.tr("Localizable", "profile.save")
    /// please fill out the profile information
    internal static let subHeader = L10n.tr("Localizable", "profile.subHeader")
    /// Surname
    internal static let surname = L10n.tr("Localizable", "profile.surname")
    internal enum Errors {
      /// The age limit is %@ years
      internal static func ageLimit(_ p1: Any) -> String {
        return L10n.tr("Localizable", "profile.errors.ageLimit", String(describing: p1))
      }
      /// Field is empty
      internal static let empty = L10n.tr("Localizable", "profile.errors.empty")
      /// Format is incorrect
      internal static let incorrectFormat = L10n.tr("Localizable", "profile.errors.incorrectFormat")
    }
  }

  internal enum Question {
    /// Are you sure you want to delete your account?
    internal static let deleteAccount = L10n.tr("Localizable", "question.deleteAccount")
    /// Are you sure you want to log out of your account?
    internal static let logoutAccount = L10n.tr("Localizable", "question.logoutAccount")
  }

  internal enum Search {
    internal enum Empty {
      /// There are no feedings points for now. Please try again a little bit later
      internal static let text = L10n.tr("Localizable", "search.empty.text")
    }
    internal enum SearchBar {
      /// Search here
      internal static let placeholder = L10n.tr("Localizable", "search.searchBar.placeholder")
    }
  }

  internal enum Segment {
    /// Cats
    internal static let cats = L10n.tr("Localizable", "segment.cats")
    /// Dogs
    internal static let dogs = L10n.tr("Localizable", "segment.dogs")
  }

  internal enum TabBar {
    /// Favourites
    internal static let favourites = L10n.tr("Localizable", "tabBar.favourites")
    /// Leader Board
    internal static let leaderBoard = L10n.tr("Localizable", "tabBar.leaderBoard")
    /// More
    internal static let more = L10n.tr("Localizable", "tabBar.more")
    /// Search
    internal static let search = L10n.tr("Localizable", "tabBar.search")
  }

  internal enum Text {
    /// You will have 1 hour to feed the point
    internal static let oneHourToFeed = L10n.tr("Localizable", "text.oneHourToFeed")
    internal enum Header {
      /// Last feeder
      internal static let lastFeeder = L10n.tr("Localizable", "text.header.lastFeeder")
    }
  }

  internal enum Toast {
    /// You have successfully logged out
    internal static let successLogout = L10n.tr("Localizable", "toast.successLogout")
    /// Your account has successfully been deleted
    internal static let userDeleted = L10n.tr("Localizable", "toast.userDeleted")
  }

  internal enum Verification {
    /// Enter verification code
    internal static let title = L10n.tr("Localizable", "verification.title")
    internal enum Alert {
      /// Cancel
      internal static let cancel = L10n.tr("Localizable", "verification.alert.cancel")
      /// Resend
      internal static let resend = L10n.tr("Localizable", "verification.alert.resend")
    }
    internal enum Error {
      /// Code digits count doesn’t fit
      internal static let codeDigitsCountDoesNotFit = L10n.tr("Localizable", "verification.error.codeDigitsCountDoesNotFit")
      /// Code request time limit exceeded
      internal static let codeRequestTimeLimitExceeded = L10n.tr("Localizable", "verification.error.codeRequestTimeLimitExceeded")
      /// Attempts to enter the verification code have ended. Try requesting the code again.
      internal static let codeTriesCountLimitExceeded = L10n.tr("Localizable", "verification.error.codeTriesCountLimitExceeded")
      /// Code unsupported next step
      internal static let codeUnsupportedNextStep = L10n.tr("Localizable", "verification.error.codeUnsupportedNextStep")
    }
    internal enum ResendCode {
      /// Resend code in
      internal static let title = L10n.tr("Localizable", "verification.resendCode.title")
    }
    internal enum Subtitle {
      /// Code was sent to destination
      internal static let empty = L10n.tr("Localizable", "verification.subtitle.empty")
      /// Code was sent to:
      internal static let filled = L10n.tr("Localizable", "verification.subtitle.filled")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
