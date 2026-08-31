import Foundation

enum AccessibilityID {
    enum Auth {
        enum Login {
            static let signInWithPhone = "auth.login.signInWithPhone"
            static let signInWithApple = "auth.login.signInWithApple"
            static let continueAsGuest = "auth.login.continueAsGuest"
            static let termsAndConditions = "auth.login.termsAndConditions"
            static let privacyPolicy = "auth.login.privacyPolicy"
        }

        enum Phone {
            static let phoneField = "auth.phone.phoneField"
            static let countryCode = "auth.phone.countryCode"
            static let passwordField = "auth.phone.passwordField"
            static let nextButton = "auth.phone.nextButton"
            static let termsAndConditions = "auth.phone.termsAndConditions"
            static let privacyPolicy = "auth.phone.privacyPolicy"
            static let countryList = "auth.phone.countryList"

            static func country(_ code: String) -> String {
                "auth.phone.country.\(code)"
            }
        }

        enum OTP {
            static let codeField = "auth.otp.codeField"
            static let digitPrefix = "auth.otp.digit"
            static let resendButton = "auth.otp.resendButton"
        }
    }

    enum Profile {
        static let nameField = "profile.nameField"
        static let surnameField = "profile.surnameField"
        static let emailField = "profile.emailField"
        static let phoneField = "profile.phoneField"
        static let countryCode = "profile.countryCode"
        static let ageConsent = "profile.ageConsent"
        static let doneButton = "profile.doneButton"
        static let saveButton = "profile.saveButton"
        static let editButton = "profile.editButton"
        static let cancelButton = "profile.cancelButton"
        static let backButton = "profile.backButton"
    }

    enum TabBar {
        static let search = "tab.search"
        static let favourites = "tab.favourites"
        static let home = "tab.home"
        static let leaderboard = "tab.leaderboard"
        static let more = "tab.more"
    }

    enum Home {
        static let categoryControl = "home.categoryControl"
        static let myLocationButton = "home.myLocationButton"
        static let feedingTimer = "home.feedingTimer"
        static let cancelFeedingButton = "home.cancelFeedingButton"
        static let alertConfirm = "home.alert.confirm"
        static let alertCancel = "home.alert.cancel"

        enum Category {
            static let dogsIndex = 0
            static let catsIndex = 1
        }
    }

    enum FeedingPoint {
        static let sheet = "feedingPoint.sheet"
        static let favoriteButton = "feedingPoint.favoriteButton"
        static let iWillFeedButton = "feedingPoint.iWillFeedButton"
        static let showOnMapButton = "feedingPoint.showOnMapButton"
        static let showMoreModeratorsButton = "feedingPoint.showMoreModeratorsButton"
        static let toggleModeratorsButton = "feedingPoint.toggleModeratorsButton"
        static let nameLabel = "feedingPoint.nameLabel"
        static let descriptionLabel = "feedingPoint.descriptionLabel"
        static let alertConfirm = "feedingPoint.alert.confirm"
        static let alertCancel = "feedingPoint.alert.cancel"
    }

    enum FeedingBooking {
        static let cancelButton = "feedingBooking.cancelButton"
        static let agreeButton = "feedingBooking.agreeButton"
    }

    enum FeedingFinished {
        static let backToHomeButton = "feedingFinished.backToHomeButton"
    }

    enum Favourites {
        static let list = "favourites.list"
        static let reloadButton = "favourites.reloadButton"

        static func cell(_ id: String) -> String {
            "favourites.cell.\(id)"
        }

        static func favoriteButton(_ id: String) -> String {
            "favourites.favoriteButton.\(id)"
        }
    }

    enum Search {
        static let filterControl = "search.filterControl"
        static let input = "search.input"
        static let list = "search.list"
        static let filterDogs = "search.filter.dogs"
        static let filterCats = "search.filter.cats"

        static func filter(_ id: String) -> String {
            switch id {
            case "0":
                return filterDogs
            case "1":
                return filterCats
            default:
                return "search.filter.\(id)"
            }
        }

        static func cell(_ id: String) -> String {
            "search.cell.\(id)"
        }

        static func favoriteButton(_ id: String) -> String {
            "search.favoriteButton.\(id)"
        }

        static func sectionHeader(_ id: String) -> String {
            "search.sectionHeader.\(id)"
        }
    }

    enum Leaderboard {
        static let list = "leaderboard.list"
    }

    enum More {
        static let menu = "more.menu"
        static let backButton = "more.backButton"

        static func item(_ route: String) -> String {
            "more.menu.\(route)"
        }

        enum FAQ {
            static func item(_ id: String) -> String {
                "more.faq.item.\(id)"
            }
        }

        enum Donate {
            static func copyButton(_ id: String) -> String {
                "more.donate.copyButton.\(id)"
            }
        }

        enum About {
            static func link(_ id: String) -> String {
                "more.about.\(id)"
            }
        }

        enum Account {
            static let deleteButton = "more.account.deleteButton"
            static let logoutButton = "more.account.logoutButton"
            static let alertConfirm = "more.account.alert.confirm"
            static let alertCancel = "more.account.alert.cancel"
        }
    }

    enum AttachPhoto {
        static let attachButton = "attachPhoto.attachButton"
        static let finishButton = "attachPhoto.finishButton"
        static let alertConfirm = "attachPhoto.alert.confirm"
        static let alertCancel = "attachPhoto.alert.cancel"

        static func removePhoto(_ index: Int) -> String {
            "attachPhoto.removePhoto.\(index)"
        }
    }
}
