// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Buttons {
    internal static let goButton = ImageAsset(name: "GoButton")
    internal static let resetButton = ImageAsset(name: "ResetButton")
  }
  internal enum Enemies {
    internal enum Obinoby {
      internal static let obinobyCelebratingA1 = ImageAsset(name: "Obinoby-CelebratingA1")
      internal static let obinobyCelebratingA2 = ImageAsset(name: "Obinoby-CelebratingA2")
      internal static let obinobyCelebratingA3 = ImageAsset(name: "Obinoby-CelebratingA3")
      internal static let obinobyNo = ImageAsset(name: "Obinoby-No")
      internal static let obinobySleeping = ImageAsset(name: "Obinoby-Sleeping")
      internal static let obinobySurpriseA1 = ImageAsset(name: "Obinoby-SurpriseA1")
      internal static let obinobySurpriseA2 = ImageAsset(name: "Obinoby-SurpriseA2")
      internal static let obinobyThinkingA1 = ImageAsset(name: "Obinoby-ThinkingA1")
      internal static let obinobyThinkingA2 = ImageAsset(name: "Obinoby-ThinkingA2")
      internal static let obinobyThinkingA3 = ImageAsset(name: "Obinoby-ThinkingA3")
      internal static let obinobyThinkingA4 = ImageAsset(name: "Obinoby-ThinkingA4")
      internal static let obinobyWaiting = ImageAsset(name: "Obinoby-Waiting")
      internal static let obinobyWaitingB1 = ImageAsset(name: "Obinoby-WaitingB1")
      internal static let obinobyWaitingB2 = ImageAsset(name: "Obinoby-WaitingB2")
      internal static let obinobyWaitingC1 = ImageAsset(name: "Obinoby-WaitingC1")
      internal static let obinobyWaitingC2 = ImageAsset(name: "Obinoby-WaitingC2")
      internal static let obinobyWaitingC3 = ImageAsset(name: "Obinoby-WaitingC3")
      internal static let obinobyWaitingC4 = ImageAsset(name: "Obinoby-WaitingC4")
      internal static let obinobyWakeUp = ImageAsset(name: "Obinoby-WakeUp")
    }
  }
  internal enum Media {
    internal static let background = ImageAsset(name: "Background")
    internal static let board = ImageAsset(name: "Board")
    internal static let boxCenterTop = ImageAsset(name: "BoxCenterTop")
    internal static let boxLeftBottom = ImageAsset(name: "BoxLeftBottom")
    internal static let boxRightBottom = ImageAsset(name: "BoxRightBottom")
    internal static let coin = ImageAsset(name: "Coin")
    internal static let coinShadow = ImageAsset(name: "CoinShadow")
    internal static let obinobyDialog = ImageAsset(name: "Obinoby-Dialog")
    internal static let paper = ImageAsset(name: "Paper")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
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
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
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

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

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
