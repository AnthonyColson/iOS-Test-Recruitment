//
//  ListingCardViewModelTests.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Testing
import Foundation
@testable import TheGoodCorner

@Suite("ListingCardViewModelTests")
final class ListingCardViewModelTests {
    private var sut: ListingCardViewModel!

    // MARK: - Fixtures
    
    init() {
        self.sut = ListingCardViewModel.mocked(locale: Locale(identifier: "fr_FR"))
    }

    // MARK: - Price formatting

    @Test(arguments: [
        ("fr_FR", "€"),
        ("en_US", "$"),
        ("en_GB", "£"),
        ("ja_JP", "¥")
    ])
    func priceUsesExpectedCurrencySymbol(localeID: String, symbol: String) {
        sut = ListingCardViewModel.mocked(price: 249.90, locale: Locale(identifier: localeID))
        #expect(sut.formattedPrice.contains(symbol))
    }

    @Test(arguments: [
        ("fr_FR", ","),
        ("en_US", "."),
        ("de_DE", ","),
        ("en_GB", ".")
    ])
    func priceUsesExpectedDecimalSeparator(localeID: String, separator: String) {
        sut = ListingCardViewModel.mocked(price: 1234.50, locale: Locale(identifier: localeID))
        #expect(sut.formattedPrice.contains(separator))
    }

    // MARK: - Date formatting

    @Test(arguments: ["fr_FR", "en_US", "en_GB", "ja_JP", "de_DE"])
    func dateContainsYearRegardlessOfLocale(localeID: String) {
        sut = ListingCardViewModel.mocked(locale: Locale(identifier: localeID))
        #expect(sut.formattedDate.contains("2026"))
    }

    @Test(arguments: [
        ("en_US", "May", "21"),
        ("fr_FR", "21", "mai")
    ])
    func dateOrdersTokensAccordingToLocale(
        localeID: String,
        firstToken: String,
        secondToken: String
    ) {
        sut = ListingCardViewModel.mocked(locale: Locale(identifier: localeID))
        let formatted = sut.formattedDate

        guard
            let firstRange = formatted.range(of: firstToken),
            let secondRange = formatted.range(of: secondToken)
        else {
            Issue.record("Expected '\(firstToken)' and '\(secondToken)' in: \(formatted)")
            return
        }
        #expect(firstRange.lowerBound < secondRange.lowerBound)
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
        sut = ListingCardViewModel.mocked(title: input, locale: Locale(identifier: "en_US"))
        #expect(sut.displayedTitle == expected)
    }

    // MARK: - Urgent badge

    @Test(arguments: [true, false])
    func shouldShowUrgentBadgeReflectsIsUrgent(isUrgent: Bool) {
        sut = ListingCardViewModel.mocked(isUrgent: isUrgent, locale: Locale(identifier: "en_US"))
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
        sut = ListingCardViewModel.mocked(isUrgent: isUrgent, locale: Locale(identifier: "en_US"))
        #expect(sut.accessibilityDescription.contains("Urgent") == shouldContainUrgent)
    }

    @Test(arguments: [
        (
            localeID: "en_US",
            title: "Vintage chair",
            isUrgent: false,
            expected: ["Vintage chair", "$", "2026"]
        ),
        (
            localeID: "fr_FR",
            title: "Chaise vintage",
            isUrgent: true,
            expected: ["Urgent", "Chaise vintage", "€", "mai"]
        )
    ])
    func accessibilityDescriptionAggregatesAllRelevantInfo(
        localeID: String,
        title: String,
        isUrgent: Bool,
        expected: [String]
    ) {
        sut = ListingCardViewModel.mocked(
            title: title,
            price: 249.90,
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

