//
//  ListingsPage+Mock.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Foundation
@testable import TheGoodCorner

extension ListingsPage {
    static func mocked(total: Int = 100,
                       page: Int = 1,
                       limit: Int = 20,
                       hasMore: Bool = true,
                       items: [ListingsItem] = [.mocked(), .mocked(), .mocked()])  -> ListingsPage {
        ListingsPage(total: total,
                     page: page,
                     limit: limit,
                     hasMore: hasMore,
                     items: items)
    }
}

extension ListingsItem {
    static func mocked(id: Int = 111,
                       categoryID: Int = 10,
                       title: String = String(),
                       description: String = String(),
                       price: Int = 100,
                       creationDate: Date = Date(),
                       isUrgent: Bool = false) -> ListingsItem {
        ListingsItem(id: id,
                     categoryID: categoryID,
                     title: title,
                     description: description,
                     price: price,
                     creationDate: creationDate,
                     isUrgent: isUrgent,
                     imagesURL: .mocked())
    }
}

extension ImagesURL {
    static func mocked(small: URL? = URL(string: "https://google.com"),
                       thumb: URL? = URL(string: "https://google.com")) -> ImagesURL {
        ImagesURL(small: small, thumb: thumb)
    }
}
