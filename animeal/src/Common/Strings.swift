// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum LoginScreen {
    /// Sign in with Apple
    internal static let signInViaApple = L10n.tr("Localizable", "loginScreen.signInViaApple")
    /// Sign in with Facebook
    internal static let signInViaFacebook = L10n.tr("Localizable", "loginScreen.signInViaFacebook")
    /// Sign in with Mobile
    internal static let signInViaMobilePhone = L10n.tr("Localizable", "loginScreen.signInViaMobilePhone")
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
