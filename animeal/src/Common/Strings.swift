// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum AddPetScreen {
    internal enum Header {
      /// It is possible to add a maximum of three photos, adding a photo is required
      internal static let info = L10n.tr("Localizable", "addPetScreen.header.info")
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

  internal enum TabBar {
    /// Favourites
    internal static let favourites = L10n.tr("Localizable", "tabBar.favourites")
    /// Leader Board
    internal static let leaderBoard = L10n.tr("Localizable", "tabBar.leaderBoard")
    /// More
    internal static let mode = L10n.tr("Localizable", "tabBar.Mode")
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
