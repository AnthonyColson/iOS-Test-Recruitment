//
//  ListingCardItem.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

public final class ListingCardItem: Equatable, Hashable, Identifiable  {

    // MARK: - Inputs

    public let id: Int
    public let imageURL: URL?
    public let title: String
    public let price: Int
    public let category: String?
    public let isUrgent: Bool

    // MARK: - Dependencies

    private let locale: Locale

    // MARK: - Inits

    public init(
        id: Int,
        imageURL: URL?,
        title: String,
        price: Int,
        category: String?,
        isUrgent: Bool,
        locale: Locale = .current
    ) {
        self.id = id
        self.imageURL = imageURL
        self.title = title
        self.price = price
        self.category = category
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

    public var formattedCategory: String? {
        if let category {
            String(localized: "Category: \(category)")
        } else {
            nil
        }
    }

    // MARK: - Accessibility

    public var accessibilityDescription: String {
        var parts: [String] = []
        if isUrgent { parts.append(String(localized: "Urgent")) }
        parts.append(displayedTitle)
        parts.append(formattedPrice)
        if let formattedCategory {
            parts.append(formattedCategory)
        }
        return parts.joined(separator: ", ")
    }

    // MARK: - Equatable & Hashable

    public static func == (lhs: ListingCardItem, rhs: ListingCardItem) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
