//
//  ListingCardIViewModel+Mock.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation
@testable import TheGoodCorner

extension ListingCardIViewModel {
    static func mocked(
        id: Int = 1,
        imagesURL: ImagesURL = ImagesURL(small: nil, thumb: nil),
        title: String = "Vintage chair",
        description: String? = nil,
        price: Int = 249,
        category: String? = "Meuble",
        isUrgent: Bool = false,
        locale: Locale = Locale(identifier: "fr_FR")
    ) -> ListingCardIViewModel {
        ListingCardIViewModel(
            id: id,
            imagesURL: imagesURL,
            title: title,
            description: description,
            price: price,
            category: category,
            isUrgent: isUrgent,
            locale: locale
        )
    }
}
