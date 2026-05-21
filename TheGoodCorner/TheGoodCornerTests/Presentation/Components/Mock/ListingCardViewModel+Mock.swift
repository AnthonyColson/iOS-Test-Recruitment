//
//  ListingCard+.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation
@testable import TheGoodCorner

extension ListingCardViewModel {
    
    private static let fixedDate: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 5
        components.day = 21
        components.hour = 12
        components.timeZone = TimeZone(identifier: "UTC")
        return Calendar(identifier: .gregorian).date(from: components)!
    }()

    static func mocked(
        title: String = "Vintage chair",
        price: Double = 249.90,
        date: Date = fixedDate,
        isUrgent: Bool = false,
        locale: Locale
    ) -> ListingCardViewModel {
        ListingCardViewModel(
            imageURL: nil,
            title: title,
            price: price,
            date: date,
            isUrgent: isUrgent,
            locale: locale
        )
    }
}
