//
//  AboutLink.swift
//  animeal
//
//  Created by Mikhail Churbanov on 1/26/23.
//

import SwiftUI
import Style

// MARK: - AboutLink
enum AboutLink: String {
    case facebook
    case instagram
    case linkedin
    case website
}

// MARK: - Extensions
extension AboutLink: Identifiable, CaseIterable {

    var id: String {
        rawValue
    }

    var disabled: Bool {
        self.urlString == nil
    }

    var image: Image {
        switch self {
        case .facebook:
            return Asset.Images.facebookIcon.swiftUIImage
        case .instagram:
            return Asset.Images.instagramIcon.swiftUIImage
        case .linkedin:
            return Asset.Images.linkedinIcon.swiftUIImage
        case .website:
            return Asset.Images.websiteIcon.swiftUIImage
        }
    }
}

// MARK: - Social Media URLs Extension
extension AboutLink {
    var appSchemeString: String? {
        switch self {
        case .facebook:
            return "fb://profile/100079867876727"

        case .instagram:
            return "instagram://user?username=animalproject.ge"

        case .linkedin:
            return "linkedin://company/animalprojectgeorgia"

        case .website:
            return nil
        }
    }

    var urlString: String? {
        switch self {
        case .facebook:
            return "https://www.facebook.com/animalprojectgeorgia/"

        case .instagram:
            return "https://www.instagram.com/animalproject.ge/"

        case .linkedin:
            return "https://www.linkedin.com/company/animalprojectgeorgia/"

        case .website:
            return nil
        }
    }
}
