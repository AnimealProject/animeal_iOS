// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum Action {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "action.cancel")
    /// Copy IBAN
    internal static let copyIBAN = L10n.tr("Localizable", "action.copyIBAN")
    /// Delete
    internal static let delete = L10n.tr("Localizable", "action.delete")
    /// Delete Account
    internal static let deleteAccount = L10n.tr("Localizable", "action.deleteAccount")
    /// I will feed
    internal static let iWillFeed = L10n.tr("Localizable", "action.iWillFeed")
    /// Log out
    internal static let logOut = L10n.tr("Localizable", "action.logOut")
    /// Ok
    internal static let ok = L10n.tr("Localizable", "action.ok")
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
    /// Help
    internal static let help = L10n.tr("Localizable", "more.help")
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
    /// E-mail
    internal static let email = L10n.tr("Localizable", "profile.email")
    /// Profile
    internal static let header = L10n.tr("Localizable", "profile.header")
    /// Name
    internal static let name = L10n.tr("Localizable", "profile.name")
    /// Phone Number
    internal static let phoneNumber = L10n.tr("Localizable", "profile.phoneNumber")
    /// please fill out the profile information
    internal static let subHeader = L10n.tr("Localizable", "profile.subHeader")
    /// Surname
    internal static let surname = L10n.tr("Localizable", "profile.surname")
  }

  internal enum Question {
    /// Are you sure you want to delete your account?
    internal static let deleteAccount = L10n.tr("Localizable", "question.deleteAccount")
    /// Are you sure you want to log out of your account?
    internal static let logoutAccount = L10n.tr("Localizable", "question.logoutAccount")
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
    internal enum Header {
      /// Last feeder
      internal static let lastFeeder = L10n.tr("Localizable", "text.header.lastFeeder")
    }
  }

  internal enum Verification {
    /// Enter verification code
    internal static let title = L10n.tr("Localizable", "verification.title")
    internal enum Error {
      /// Code digits count doesn’t fit
      internal static let codeDigitsCountDoesNotFit = L10n.tr("Localizable", "verification.error.codeDigitsCountDoesNotFit")
      /// Code request time limit exceeded
      internal static let codeRequestTimeLimitExceeded = L10n.tr("Localizable", "verification.error.codeRequestTimeLimitExceeded")
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
