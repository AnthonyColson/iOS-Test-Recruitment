//
//  DetailsViewModel.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Foundation

final class DetailsViewModel {

    // MARK: - Inputs

    private let item: ListingCardIViewModel

    // MARK: - Init

    init(item: ListingCardIViewModel) {
        self.item = item
    }

    // MARK: - Public Properties

    var title: String { item.displayedTitle }

    var imageURL: URL? { item.imagesURL.thumb }

    var formattedPrice: String { item.formattedPrice }

    var formattedCategory: String? { item.formattedCategory }

    var isUrgent: Bool { item.isUrgent }

    /// Trimmed description; `nil` if the item has none or only whitespace,
    /// so the view can decide whether to render the section at all.
    var description: String? {
        guard
            let trimmed = item.description?.trimmingCharacters(in: .whitespacesAndNewlines),
            !trimmed.isEmpty
        else { return nil }
        return trimmed
    }

    var accessibilityDescription: String { item.accessibilityDescription }
}
