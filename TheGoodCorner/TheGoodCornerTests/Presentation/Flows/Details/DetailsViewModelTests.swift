//
//  DetailsViewModelTests.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Testing
import Foundation
@testable import TheGoodCorner

@Suite("DetailsViewModelTests")
struct DetailsViewModelTests {

    // MARK: - Passthrough properties

    @Test func passthroughPropertiesReflectTheUnderlyingItem() {
        let thumb = URL(string: "https://example.com/thumb.jpg")
        let item = ListingCardItem.mocked(
            imagesURL: ImagesURL(small: nil, thumb: thumb),
            title: "Chair",
            price: 99,
            category: "Meuble",
            isUrgent: true
        )

        let sut = DetailsViewModel(item: item)

        #expect(sut.title == "Chair")
        #expect(sut.imageURL == thumb)
        #expect(sut.isUrgent == true)
        #expect(sut.formattedCategory?.contains("Meuble") == true)
        #expect(sut.formattedPrice.contains("€"))    // locale is fr_FR by default in mock
    }

    // MARK: - Description trimming

    @Test(arguments: [
        (nil,                          nil),
        ("",                           nil),
        ("   ",                        nil),
        ("\n\t",                       nil),
        ("Some text",                  "Some text"),
        ("   Some text   ",            "Some text"),
        ("\nSome text\n",              "Some text"),
        ("Multi\nline",                "Multi\nline"), 
    ] as [(String?, String?)])
    func descriptionTrimsAndReturnsNilWhenEmpty(input: String?, expected: String?) {
        let sut = DetailsViewModel(
            item: ListingCardItem.mocked(description: input)
        )

        #expect(sut.description == expected)
    }

    // MARK: - Title trimming

    @Test func titleTrimsLeadingAndTrailingWhitespace() {
        let sut = DetailsViewModel(
            item: ListingCardItem.mocked(title: "   Vintage chair   ")
        )
        #expect(sut.title == "Vintage chair")
    }

    // MARK: - Accessibility passthrough

    @Test func accessibilityDescriptionAggregatesUrgentAndTitle() {
        let sut = DetailsViewModel(
            item: ListingCardItem.mocked(title: "Chair", isUrgent: true)
        )
        #expect(sut.accessibilityDescription.contains("Urgent"))
        #expect(sut.accessibilityDescription.contains("Chair"))
    }
}
