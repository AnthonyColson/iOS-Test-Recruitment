//
//  ListingCardIViewModelTests.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Testing
import Foundation
@testable import TheGoodCorner

@Suite("ListingCardIViewModelTests")
final class ListingCardIViewModelTests {
    private var sut: ListingCardIViewModel!

    // MARK: - Fixtures
    
    init() {
        self.sut = ListingCardIViewModel.mocked(locale: Locale(identifier: "fr_FR"))
    }

    // MARK: - Price formatting

    @Test(arguments: [
        ("fr_FR", "€"),
        ("en_US", "$"),
        ("en_GB", "£"),
        ("ja_JP", "¥")
    ])
    func priceUsesExpectedCurrencySymbol(localeID: String, symbol: String) {
        sut = ListingCardIViewModel.mocked(price: 249, locale: Locale(identifier: localeID))
        #expect(sut.formattedPrice.contains(symbol))
    }

    @Test(arguments: [
        ("fr_FR", ","),
        ("en_US", "."),
        ("de_DE", ","),
        ("en_GB", ".")
    ])
    func priceUsesExpectedDecimalSeparator(localeID: String, separator: String) {
        sut = ListingCardIViewModel.mocked(price: 1234, locale: Locale(identifier: localeID))
        #expect(sut.formattedPrice.contains(separator))
    }

    // MARK: - Title

    @Test(arguments: [
        ("   Vintage chair   ",         "Vintage chair"),
        ("\nVintage chair\n",           "Vintage chair"),
        ("\t Vintage chair \t",         "Vintage chair"),
        ("Vintage chair",               "Vintage chair"),
        ("Vintage  leather  chair",     "Vintage  leather  chair")
    ])
    func displayedTitleTrimsOnlyOuterWhitespace(input: String, expected: String) {
        sut = ListingCardIViewModel.mocked(title: input, locale: Locale(identifier: "en_US"))
        #expect(sut.displayedTitle == expected)
    }

    // MARK: - Urgent badge

    @Test(arguments: [true, false])
    func shouldShowUrgentBadgeReflectsIsUrgent(isUrgent: Bool) {
        sut = ListingCardIViewModel.mocked(isUrgent: isUrgent, locale: Locale(identifier: "en_US"))
        #expect(sut.shouldShowUrgentBadge == isUrgent)
    }

    // MARK: - Accessibility

    @Test(arguments: [
        (true,  true),
        (false, false)
    ])
    func accessibilityDescriptionMentionsUrgentOnlyWhenUrgent(
        isUrgent: Bool,
        shouldContainUrgent: Bool
    ) {
        sut = ListingCardIViewModel.mocked(isUrgent: isUrgent, locale: Locale(identifier: "en_US"))
        #expect(sut.accessibilityDescription.contains("Urgent") == shouldContainUrgent)
    }

    @Test(arguments: [
        (
            localeID: "en_US",
            title: "Vintage chair",
            isUrgent: false,
            expected: ["Vintage chair", "$", "test"]
        ),
        (
            localeID: "fr_FR",
            title: "Chaise vintage",
            isUrgent: true,
            expected: ["Urgent", "Chaise vintage", "€", "test"]
        )
    ])
    func accessibilityDescriptionAggregatesAllRelevantInfo(
        localeID: String,
        title: String,
        isUrgent: Bool,
        expected: [String]
    ) {
        sut = ListingCardIViewModel.mocked(
            title: title,
            price: 249,
            category: "test",
            isUrgent: isUrgent,
            locale: Locale(identifier: localeID)
        )
        let description = sut.accessibilityDescription

        for substring in expected {
            #expect(
                description.contains(substring),
                "Expected '\(substring)' in '\(description)' (locale: \(localeID))"
            )
        }
    }
}

