//
//  ListingCardViewModel.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

public final class ListingCardViewModel {

    // MARK: - Inputs

    public let imageURL: URL?
    public let title: String
    public let price: Double
    public let date: Date
    public let isUrgent: Bool

    // MARK: - Dependencies

    private let locale: Locale

    // MARK: - Init

    public init(
        imageURL: URL?,
        title: String,
        price: Double,
        date: Date,
        isUrgent: Bool = false,
        locale: Locale = .current
    ) {
        self.imageURL = imageURL
        self.title = title
        self.price = price
        self.date = date
        self.isUrgent = isUrgent
        self.locale = locale
    }

    // MARK: - Display

    public var shouldShowUrgentBadge: Bool { isUrgent }

    public var displayedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var formattedPrice: String {
        let code = locale.currency?.identifier ?? "EUR"
        return price.formatted(
            .currency(code: code).locale(locale)
        )
    }

    public var formattedDate: String {
        date.formatted(
            .dateTime
                .day().month().year()
                .locale(locale)
        )
    }

    // MARK: - Accessibility

    public var accessibilityDescription: String {
        var parts: [String] = []
        if isUrgent { parts.append("Urgent") }
        parts.append(displayedTitle)
        parts.append(formattedPrice)
        parts.append(formattedDate)
        return parts.joined(separator: ", ")
    }
}
