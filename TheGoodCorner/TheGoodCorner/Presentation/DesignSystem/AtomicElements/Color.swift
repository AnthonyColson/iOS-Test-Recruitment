//
//  AppColor.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI
import UIKit

public enum AppColor {

    // MARK: - Backgrounds

    public static let background = dynamic(light: 0xFFFFFF, dark: 0x121212)
    public static let surface = dynamic(light: 0xF5F5F5, dark: 0x1E1E1E)
    public static let surfaceMuted = dynamic(light: 0xEDEDED, dark: 0x2A2A2A)

    // MARK: - Text

    public static let textPrimary = dynamic(light: 0x111111, dark: 0xFFFFFF)
    public static let textSecondary = dynamic(light: 0x555555, dark: 0xB0B0B0)
    public static let textDisabled = dynamic(light: 0x9E9E9E, dark: 0x6E6E6E)

    // MARK: - Brand

    public static let primary = dynamic(light: 0xEC5A13, dark: 0xFF8A50)
    public static let accent = dynamic(light: 0x0288D1, dark: 0x4FC3F7)

    // MARK: - Semantic

    public static let success = dynamic(light: 0x2E7D32, dark: 0x66BB6A)
    public static let warning = dynamic(light: 0xEF6C00, dark: 0xFFB74D)
    public static let error   = dynamic(light: 0xC62828, dark: 0xEF5350)
    public static let info    = dynamic(light: 0x1565C0, dark: 0x64B5F6)

    // MARK: - Borders & dividers

    public static let border = dynamic(light: 0xE0E0E0, dark: 0x2C2C2C)
    public static let borderEmphasis = dynamic(light: 0xBDBDBD, dark: 0x4A4A4A)

    // MARK: - Helpers
    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        })
    }
}

private extension UIColor {
    /// Creates a `UIColor` from a 24-bit RGB hex value (e.g. `0xEC5A13`).
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red   = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8)  & 0xFF) / 255.0
        let blue  = CGFloat( hex        & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
