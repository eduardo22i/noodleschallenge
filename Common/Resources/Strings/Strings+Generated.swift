// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI

// MARK: - Strings

public enum L10n {
  public enum Dialog {
    public enum Enemy {
      /// Lalala! I won!
      public static let celebrating = LocalizedString(lookupKey: "dialog.enemy.celebrating")
      /// OMG! This is not possible! NOOO! \nYou won the NOODLES!
      public static let crying = LocalizedString(lookupKey: "dialog.enemy.crying")
      /// The rules are simple. \nWe are going to take turns.
      public static let instructions1 = LocalizedString(lookupKey: "dialog.enemy.instructions_1")
      /// We have %d boxes,\neach box have different amount of coins.
      public static func instructions2(_ p1: Int) -> LocalizedString {
        LocalizedString(lookupKey: "dialog.enemy.instructions_2", [p1])
      }
      /// In your turn, \nremove all the coins you want \nbut only from 1 box.
      public static let instructions3 = LocalizedString(lookupKey: "dialog.enemy.instructions_3")
      /// The player who picks\n the LAST coin from ALL boxes, loses the game.
      public static let instructions4 = LocalizedString(lookupKey: "dialog.enemy.instructions_4")
      /// Please, start!
      public static let instructions5 = LocalizedString(lookupKey: "dialog.enemy.instructions_5")
      /// ...
      public static let instructions6 = LocalizedString(lookupKey: "dialog.enemy.instructions_6")
      /// Haha! Scared?
      public static let thinking1 = LocalizedString(lookupKey: "dialog.enemy.thinking_1")
      /// Please, don't cry!
      public static let thinking2 = LocalizedString(lookupKey: "dialog.enemy.thinking_2")
      /// Okay... Your turn, try harder!
      public static let thinking3 = LocalizedString(lookupKey: "dialog.enemy.thinking_3")
      /// Looks like you will lose
      public static let thinking4 = LocalizedString(lookupKey: "dialog.enemy.thinking_4")
      /// Let me think!
      public static let waiting1 = LocalizedString(lookupKey: "dialog.enemy.waiting_1")
      /// LOL! What was that move?
      public static let waiting2 = LocalizedString(lookupKey: "dialog.enemy.waiting_2")
      /// I guess you enjoy making mistakes
      public static let waiting3 = LocalizedString(lookupKey: "dialog.enemy.waiting_3")
      /// Thanks! I'm closer to my victory
      public static let waiting4 = LocalizedString(lookupKey: "dialog.enemy.waiting_4")
      /// Let me analyze this...
      public static let waiting5 = LocalizedString(lookupKey: "dialog.enemy.waiting_5")
      /// ... ZZZ
      public static let wakeUp1 = LocalizedString(lookupKey: "dialog.enemy.wakeUp_1")
      /// Ahh! A new challenger? \nOkay! I Always win!
      public static let wakeUp2 = LocalizedString(lookupKey: "dialog.enemy.wakeUp_2")
      /// Win to me and I'll give you the best NOODLES!
      public static let wakeUp3 = LocalizedString(lookupKey: "dialog.enemy.wakeUp_3")
    }
  }
}

// MARK: - Implementation Details

extension L10n {
  fileprivate static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

public struct LocalizedString {
    private let lookupKey: String

    var options = String.LocalizationOptions()

    internal init(lookupKey: String, _ args: [CVarArg] = []) {
        self.lookupKey = lookupKey
        self.options.replacements = args
    }

    var key: String.LocalizationValue {
        String.LocalizationValue(lookupKey)
    }

    var text: String {
        String(format: String(localized: key), arguments: options.replacements ?? [])
    }
}

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
      return Bundle.module
    #else
      return Bundle(for: BundleToken.self)
    #endif
  }()
}
