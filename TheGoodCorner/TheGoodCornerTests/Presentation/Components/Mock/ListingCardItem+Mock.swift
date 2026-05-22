//
//  ListingCard+.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation
@testable import TheGoodCorner

extension ListingCardItem {
    static func mocked(
        id: Int = 1,
        title: String = "Vintage chair",
        price: Int = 249,
        category: String = "Meuble",
        isUrgent: Bool = false,
        locale: Locale
    ) -> ListingCardItem {
        ListingCardItem(
            id: id,
            imageURL: nil,
            title: title,
            price: price,
            category: category,
            isUrgent: isUrgent,
            locale: locale
        )
    }
}
