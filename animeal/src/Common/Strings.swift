// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum About {
    /// App version
    internal static let appVersion = L10n.tr("Localizable", "about.appVersion", fallback: "App version")
  }
  internal enum Action {
    /// Agree
    internal static let agree = L10n.tr("Localizable", "action.agree", fallback: "Agree")
    /// Back to home
    internal static let backToHome = L10n.tr("Localizable", "action.backToHome", fallback: "Back to home")
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "action.cancel", fallback: "Cancel")
    /// Copy IBAN
    internal static let copyIBAN = L10n.tr("Localizable", "action.copyIBAN", fallback: "Copy IBAN")
    /// Delete
    internal static let delete = L10n.tr("Localizable", "action.delete", fallback: "Delete")
    /// Delete Account
    internal static let deleteAccount = L10n.tr("Localizable", "action.deleteAccount", fallback: "Delete Account")
    /// Finish
    internal static let finish = L10n.tr("Localizable", "action.finish", fallback: "Finish")
    /// Got it
    internal static let gotIt = L10n.tr("Localizable", "action.gotIt", fallback: "Got it")
    /// I will feed
    internal static let iWillFeed = L10n.tr("Localizable", "action.iWillFeed", fallback: "I will feed")
    /// Log out
    internal static let logOut = L10n.tr("Localizable", "action.logOut", fallback: "Log out")
    /// No
    internal static let no = L10n.tr("Localizable", "action.no", fallback: "No")
    /// No, thanks
    internal static let noThanks = L10n.tr("Localizable", "action.noThanks", fallback: "No, thanks")
    /// Ok
    internal static let ok = L10n.tr("Localizable", "action.ok", fallback: "Ok")
    /// Open settings
    internal static let openSettings = L10n.tr("Localizable", "action.openSettings", fallback: "Open settings")
    /// Show on map
    internal static let showOnMap = L10n.tr("Localizable", "action.showOnMap", fallback: "Show on map")
    /// Yes
    internal static let yes = L10n.tr("Localizable", "action.yes", fallback: "Yes")
  }
  internal enum Attach {
    internal enum Photo {
      internal enum Delete {
        /// Are you sure you want to delete this photo?
        internal static let message = L10n.tr("Localizable", "attach.photo.delete.message", fallback: "Are you sure you want to delete this photo?")
      }
      internal enum Hint {
        /// Please take pictures where pet and food is detected
        internal static let text = L10n.tr("Localizable", "attach.photo.hint.text", fallback: "Please take pictures where pet and food is detected")
      }
    }
  }
  internal enum Donate {
    /// Donate
    internal static let title = L10n.tr("Localizable", "donate.title", fallback: "Donate")
    internal enum Copy {
      /// Text is copied
      internal static let text = L10n.tr("Localizable", "donate.copy.text", fallback: "Text is copied")
    }
    internal enum Footer {
      /// Thank you for donating!
      internal static let text = L10n.tr("Localizable", "donate.footer.text", fallback: "Thank you for donating!")
    }
    internal enum Header {
      /// We can leave a donation for animals and in support of the developers
      internal static let text = L10n.tr("Localizable", "donate.header.text", fallback: "We can leave a donation for animals and in support of the developers")
    }
  }
  internal enum Errors {
    /// Oops something goes wrong!
    internal static let somthingWrong = L10n.tr("Localizable", "errors.somthingWrong", fallback: "Oops something goes wrong!")
  }
  internal enum Faq {
    /// FAQ
    internal static let title = L10n.tr("Localizable", "faq.title", fallback: "FAQ")
    internal enum Footer {
      /// Didn't find your question here or have issues?
      /// Please contact us at %@
      internal static func text(_ p1: Any) -> String {
        return L10n.tr("Localizable", "faq.footer.text", String(describing: p1), fallback: "Didn't find your question here or have issues?\nPlease contact us at %@")
      }
    }
    internal enum Header {
      /// If you have any questions please check our FAQ section below
      internal static let text = L10n.tr("Localizable", "faq.header.text", fallback: "If you have any questions please check our FAQ section below")
    }
  }
  internal enum Favourites {
    /// You don't have favorite feeding points yet. Press the heart button on the feeding point details to add that one as favourite
    internal static let empty = L10n.tr("Localizable", "favourites.empty", fallback: "You don't have favorite feeding points yet. Press the heart button on the feeding point details to add that one as favourite")
    /// Favorites
    internal static let header = L10n.tr("Localizable", "favourites.header", fallback: "Favorites")
  }
  internal enum Feeding {
    internal enum Alert {
      /// Do you really want to cancel feeding?
      internal static let cancelFeeding = L10n.tr("Localizable", "feeding.alert.cancelFeeding", fallback: "Do you really want to cancel feeding?")
      /// Another user has booked the feeding for this feeding point
      internal static let feedingPointHasBooked = L10n.tr("Localizable", "feeding.alert.feedingPointHasBooked", fallback: "Another user has booked the feeding for this feeding point")
      /// Your feeding timer is over. You can book a new feeding from the home page.
      internal static let feedingTimerOver = L10n.tr("Localizable", "feeding.alert.feedingTimerOver", fallback: "Your feeding timer is over. You can book a new feeding from the home page.")
      /// To continue please grant the permission to use the Camera
      internal static let grantCameraPermission = L10n.tr("Localizable", "feeding.alert.grantCameraPermission", fallback: "To continue please grant the permission to use the Camera")
      /// We can calculate the route to the feeding point. To use the function please switch on the Location service
      internal static let grantLocationPermission = L10n.tr("Localizable", "feeding.alert.grantLocationPermission", fallback: "We can calculate the route to the feeding point. To use the function please switch on the Location service")
    }
    internal enum Error {
      /// You can't start feeding while another one is in progress
      internal static let otherFeedingRunning = L10n.tr("Localizable", "feeding.error.otherFeedingRunning", fallback: "You can't start feeding while another one is in progress")
    }
    internal enum Status {
      /// Newly fed
      internal static let fed = L10n.tr("Localizable", "feeding.status.fed", fallback: "Newly fed")
      /// Feeding in progress
      internal static let inprogress = L10n.tr("Localizable", "feeding.status.inprogress", fallback: "Feeding in progress")
      /// There is no food
      internal static let starved = L10n.tr("Localizable", "feeding.status.starved", fallback: "There is no food")
    }
  }
  internal enum LeaderBoard {
    /// Leaderboard will show the rating of volunteers
    internal static let empty = L10n.tr("Localizable", "leaderBoard.empty", fallback: "Leaderboard will show the rating of volunteers")
    /// Leaderboard
    internal static let header = L10n.tr("Localizable", "leaderBoard.header", fallback: "Leaderboard")
  }
  internal enum LoginScreen {
    /// Sign in with Apple
    internal static let signInViaApple = L10n.tr("Localizable", "loginScreen.signInViaApple", fallback: "Sign in with Apple")
    /// Sign in with Facebook
    internal static let signInViaFacebook = L10n.tr("Localizable", "loginScreen.signInViaFacebook", fallback: "Sign in with Facebook")
    /// Sign in with Mobile
    internal static let signInViaMobilePhone = L10n.tr("Localizable", "loginScreen.signInViaMobilePhone", fallback: "Sign in with Mobile")
    /// Some of them are homeless, they need your help
    internal static let text = L10n.tr("Localizable", "loginScreen.text", fallback: "Some of them are homeless, they need your help")
    /// Take care of pets
    internal static let title = L10n.tr("Localizable", "loginScreen.title", fallback: "Take care of pets")
  }
  internal enum More {
    /// About (terms and conditions)
    internal static let about = L10n.tr("Localizable", "more.about", fallback: "About (terms and conditions)")
    /// Who are we?
    /// Animal Project was founded in 2020 by animal lovers with different professions and experiences. For decades, our team members have been independently helping strays and raising awareness through personal channels.
    /// 
    /// What is our goal?
    /// We exist so that dogs and cats no longer have to live in the streets of Georgia. Our goal is to create a habitable, comfortable environment for companion animals and raise awareness within our communities.
    /// 
    /// How are we working on this goal?
    /// Our team heavily relies on international best practices and experience. Our areas of work include:
    /// · Raising social awareness;
    /// · Advocating with the government;
    /// · Charitable and humanitarian projects in collaboration with the private sector, donor organizations, and local communities
    internal static let aboutContent = L10n.tr("Localizable", "more.aboutContent", fallback: "Who are we?\nAnimal Project was founded in 2020 by animal lovers with different professions and experiences. For decades, our team members have been independently helping strays and raising awareness through personal channels.\n\nWhat is our goal?\nWe exist so that dogs and cats no longer have to live in the streets of Georgia. Our goal is to create a habitable, comfortable environment for companion animals and raise awareness within our communities.\n\nHow are we working on this goal?\nOur team heavily relies on international best practices and experience. Our areas of work include:\n· Raising social awareness;\n· Advocating with the government;\n· Charitable and humanitarian projects in collaboration with the private sector, donor organizations, and local communities")
    /// About
    internal static let aboutShort = L10n.tr("Localizable", "more.aboutShort", fallback: "About")
    /// Account
    internal static let account = L10n.tr("Localizable", "more.account", fallback: "Account")
    /// Donate
    internal static let donate = L10n.tr("Localizable", "more.donate", fallback: "Donate")
    /// FAQ
    internal static let faq = L10n.tr("Localizable", "more.faq", fallback: "FAQ")
    /// Profile Page
    internal static let profilePage = L10n.tr("Localizable", "more.profilePage", fallback: "Profile Page")
  }
  internal enum Phone {
    /// Please, enter your phone
    internal static let title = L10n.tr("Localizable", "phone.title", fallback: "Please, enter your phone")
    internal enum Errors {
      /// Required fields are empty
      internal static let empty = L10n.tr("Localizable", "phone.errors.empty", fallback: "Required fields are empty")
      /// Format of the phone number isn't correct
      internal static let incorrectPhone = L10n.tr("Localizable", "phone.errors.incorrectPhone", fallback: "Format of the phone number isn't correct")
    }
    internal enum Fields {
      /// Password
      internal static let passwordTitlle = L10n.tr("Localizable", "phone.fields.passwordTitlle", fallback: "Password")
      /// Phone Number
      internal static let phoneTitlle = L10n.tr("Localizable", "phone.fields.phoneTitlle", fallback: "Phone Number")
    }
  }
  internal enum Profile {
    /// Birthdate
    internal static let birthDate = L10n.tr("Localizable", "profile.birthDate", fallback: "Birthdate")
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "profile.cancel", fallback: "Cancel")
    /// Done
    internal static let done = L10n.tr("Localizable", "profile.done", fallback: "Done")
    /// Edit
    internal static let edit = L10n.tr("Localizable", "profile.edit", fallback: "Edit")
    /// E-mail
    internal static let email = L10n.tr("Localizable", "profile.email", fallback: "E-mail")
    /// Profile
    internal static let header = L10n.tr("Localizable", "profile.header", fallback: "Profile")
    /// Name
    internal static let name = L10n.tr("Localizable", "profile.name", fallback: "Name")
    /// Phone Number
    internal static let phoneNumber = L10n.tr("Localizable", "profile.phoneNumber", fallback: "Phone Number")
    /// Save
    internal static let save = L10n.tr("Localizable", "profile.save", fallback: "Save")
    /// Please fill out the profile information
    internal static let subHeader = L10n.tr("Localizable", "profile.subHeader", fallback: "Please fill out the profile information")
    /// Surname
    internal static let surname = L10n.tr("Localizable", "profile.surname", fallback: "Surname")
    internal enum Cancel {
      /// Do you really want to cancel the registration?
      internal static let dialogHeader = L10n.tr("Localizable", "profile.cancel.dialogHeader", fallback: "Do you really want to cancel the registration?")
    }
    internal enum DiscardEdits {
      /// Do you really want to discard the changes?
      internal static let dialogHeader = L10n.tr("Localizable", "profile.discardEdits.dialogHeader", fallback: "Do you really want to discard the changes?")
    }
    internal enum Errors {
      /// The age limit is %@ years
      internal static func ageLimit(_ p1: Any) -> String {
        return L10n.tr("Localizable", "profile.errors.ageLimit", String(describing: p1), fallback: "The age limit is %@ years")
      }
      /// Field is empty
      internal static let empty = L10n.tr("Localizable", "profile.errors.empty", fallback: "Field is empty")
      /// Must contain only letters
      internal static let incorrectCharacters = L10n.tr("Localizable", "profile.errors.incorrectCharacters", fallback: "Must contain only letters")
      /// Length must be between 2 and 35
      internal static let incorrectCharactersLength = L10n.tr("Localizable", "profile.errors.incorrectCharactersLength", fallback: "Length must be between 2 and 35")
      /// Format is incorrect
      internal static let incorrectFormat = L10n.tr("Localizable", "profile.errors.incorrectFormat", fallback: "Format is incorrect")
    }
  }
  internal enum Question {
    /// Are you sure you want to delete your account?
    internal static let deleteAccount = L10n.tr("Localizable", "question.deleteAccount", fallback: "Are you sure you want to delete your account?")
    /// Are you sure you want to log out of your account?
    internal static let logoutAccount = L10n.tr("Localizable", "question.logoutAccount", fallback: "Are you sure you want to log out of your account?")
  }
  internal enum Search {
    internal enum Empty {
      /// There are no feedings points for now. Please try again a little bit later
      internal static let text = L10n.tr("Localizable", "search.empty.text", fallback: "There are no feedings points for now. Please try again a little bit later")
    }
    internal enum SearchBar {
      /// Search here
      internal static let placeholder = L10n.tr("Localizable", "search.searchBar.placeholder", fallback: "Search here")
    }
  }
  internal enum Segment {
    /// Cats
    internal static let cats = L10n.tr("Localizable", "segment.cats", fallback: "Cats")
    /// Dogs
    internal static let dogs = L10n.tr("Localizable", "segment.dogs", fallback: "Dogs")
  }
  internal enum TabBar {
    /// Favorites
    internal static let favourites = L10n.tr("Localizable", "tabBar.favourites", fallback: "Favorites")
    /// Leaderboard
    internal static let leaderBoard = L10n.tr("Localizable", "tabBar.leaderBoard", fallback: "Leaderboard")
    /// More
    internal static let more = L10n.tr("Localizable", "tabBar.more", fallback: "More")
    /// Search
    internal static let search = L10n.tr("Localizable", "tabBar.search", fallback: "Search")
  }
  internal enum Text {
    /// Animals are fed
    internal static let animalsAreFed = L10n.tr("Localizable", "text.animalsAreFed", fallback: "Animals are fed")
    /// left
    internal static let `left` = L10n.tr("Localizable", "text.left", fallback: "left")
    /// You will have 1 hour to feed the point
    internal static let oneHourToFeed = L10n.tr("Localizable", "text.oneHourToFeed", fallback: "You will have 1 hour to feed the point")
    /// Thank You!
    internal static let thankYou = L10n.tr("Localizable", "text.thankYou", fallback: "Thank You!")
    internal enum Header {
      /// Last feeder
      internal static let lastFeeder = L10n.tr("Localizable", "text.header.lastFeeder", fallback: "Last feeder")
    }
  }
  internal enum Toast {
    /// You have successfully logged out
    internal static let successLogout = L10n.tr("Localizable", "toast.successLogout", fallback: "You have successfully logged out")
    /// Your account has successfully been deleted
    internal static let userDeleted = L10n.tr("Localizable", "toast.userDeleted", fallback: "Your account has successfully been deleted")
  }
  internal enum Verification {
    /// Enter verification code
    internal static let title = L10n.tr("Localizable", "verification.title", fallback: "Enter verification code")
    internal enum Alert {
      /// Cancel
      internal static let cancel = L10n.tr("Localizable", "verification.alert.cancel", fallback: "Cancel")
      /// Next
      internal static let next = L10n.tr("Localizable", "verification.alert.next", fallback: "Next")
      /// Resend
      internal static let resend = L10n.tr("Localizable", "verification.alert.resend", fallback: "Resend")
    }
    internal enum Error {
      /// Code digits count doesn’t fit
      internal static let codeDigitsCountDoesNotFit = L10n.tr("Localizable", "verification.error.codeDigitsCountDoesNotFit", fallback: "Code digits count doesn’t fit")
      /// Code request time limit exceeded
      internal static let codeRequestTimeLimitExceeded = L10n.tr("Localizable", "verification.error.codeRequestTimeLimitExceeded", fallback: "Code request time limit exceeded")
      /// Attempts to enter the verification code have ended. Try requesting the code again.
      internal static let codeTriesCountLimitExceeded = L10n.tr("Localizable", "verification.error.codeTriesCountLimitExceeded", fallback: "Attempts to enter the verification code have ended. Try requesting the code again.")
      /// Code unsupported next step
      internal static let codeUnsupportedNextStep = L10n.tr("Localizable", "verification.error.codeUnsupportedNextStep", fallback: "Code unsupported next step")
    }
    internal enum ResendCode {
      /// Resend code
      internal static let title = L10n.tr("Localizable", "verification.resendCode.title", fallback: "Resend code")
      /// Resend code in
      internal static let titleTime = L10n.tr("Localizable", "verification.resendCode.titleTime", fallback: "Resend code in")
    }
    internal enum Subtitle {
      /// Code was sent to destination
      internal static let empty = L10n.tr("Localizable", "verification.subtitle.empty", fallback: "Code was sent to destination")
      /// Code was sent to:
      internal static let filled = L10n.tr("Localizable", "verification.subtitle.filled", fallback: "Code was sent to:")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
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
