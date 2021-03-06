// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public enum Colors {
    public static let battleshipGrey = ColorAsset(name: "BattleshipGrey")
    public static let blueWhale = ColorAsset(name: "BlueWhale")
    public static let carminePink = ColorAsset(name: "CarminePink")
    public static let dark = ColorAsset(name: "Dark")
    public static let darkSkyBlue = ColorAsset(name: "DarkSkyBlue")
    public static let darkTurquoise = ColorAsset(name: "DarkTurquoise")
    public static let desertStorm = ColorAsset(name: "DesertStorm")
    public static let light = ColorAsset(name: "Light")
    public static let osloGrey = ColorAsset(name: "OsloGrey")
  }
  public enum Images {
    public static let refreshIcon = ImageAsset(name: "refresh_icon")
    public static let catHungryHigh = ImageAsset(name: "cat_hungry_high")
    public static let catHungryLow = ImageAsset(name: "cat_hungry_low")
    public static let catHungryMedium = ImageAsset(name: "cat_hungry_medium")
    public static let dogHungryHigh = ImageAsset(name: "dog_hungry_high")
    public static let dogHungryLow = ImageAsset(name: "dog_hungry_low")
    public static let dogHungryMedium = ImageAsset(name: "dog_hungry_medium")
    public static let favouriteHungryHigh = ImageAsset(name: "favourite_hungry_high")
    public static let favouriteHungryLow = ImageAsset(name: "favourite_hungry_low")
    public static let favouriteHungryMedium = ImageAsset(name: "favourite_hungry_medium")
    public static let myLocation = ImageAsset(name: "my_location")
    public static let onboardingFeed = ImageAsset(name: "onboarding_feed")
    public static let calendar = ImageAsset(name: "calendar")
    public static let signInApple = ImageAsset(name: "sign_in_apple")
    public static let signInFacebook = ImageAsset(name: "sign_in_facebook")
    public static let signInMobile = ImageAsset(name: "sign_in_mobile")
    public static let glass = ImageAsset(name: "glass")
    public static let heart = ImageAsset(name: "heart")
    public static let home = ImageAsset(name: "home")
    public static let more = ImageAsset(name: "more")
    public static let podium = ImageAsset(name: "podium")
    public static let animealLogo = ImageAsset(name: "animeal_logo")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ColorAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  public func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  public var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

public extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
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
