//
//  Typo.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI

public enum TypoSize {
    public static let overline: CGFloat = 11
    public static let caption: CGFloat = 12
    public static let footnote: CGFloat = 13
    public static let bodySmall: CGFloat = 15
    public static let body: CGFloat = 16
    public static let callout: CGFloat = 17
    public static let title3: CGFloat = 20
    public static let title2: CGFloat = 24
    public static let title1: CGFloat = 28
    public static let largeTitle: CGFloat = 34
    public static let display: CGFloat = 48
}

public enum TypoWeight {
    public static let regular: Font.Weight  = .regular
    public static let medium: Font.Weight   = .medium
    public static let semibold: Font.Weight = .semibold
    public static let bold: Font.Weight     = .bold
}


public enum Typo {
    public static let overline   = Font.system(size: TypoSize.overline,   weight: TypoWeight.medium)
    public static let caption    = Font.system(size: TypoSize.caption,    weight: TypoWeight.regular)
    public static let footnote   = Font.system(size: TypoSize.footnote,   weight: TypoWeight.regular)
    public static let bodySmall  = Font.system(size: TypoSize.bodySmall,  weight: TypoWeight.regular)
    public static let body       = Font.system(size: TypoSize.body,       weight: TypoWeight.regular)
    public static let bodyBold   = Font.system(size: TypoSize.body,       weight: TypoWeight.semibold)
    public static let callout    = Font.system(size: TypoSize.callout,    weight: TypoWeight.medium)
    public static let title3     = Font.system(size: TypoSize.title3,     weight: TypoWeight.semibold)
    public static let title2     = Font.system(size: TypoSize.title2,     weight: TypoWeight.semibold)
    public static let title1     = Font.system(size: TypoSize.title1,     weight: TypoWeight.bold)
    public static let largeTitle = Font.system(size: TypoSize.largeTitle, weight: TypoWeight.bold)
    public static let display    = Font.system(size: TypoSize.display,    weight: TypoWeight.bold)
}
