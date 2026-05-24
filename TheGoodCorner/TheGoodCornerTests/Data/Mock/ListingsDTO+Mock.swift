//
//  ListingsDTO+Mock.swift
//  TheGoodCornerTests
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Foundation
@testable import TheGoodCorner

extension ListingsDTO {
    static func mocked(
        total: Int = 100,
        page: Int = 1,
        limit: Int = 10,
        hasMore: Bool = true,
        items: [ListingsItemDTO] = [.mocked(), .mocked(), .mocked()]
    ) -> ListingsDTO {
        ListingsDTO(
            total: total,
            page: page,
            limit: limit,
            hasMore: hasMore,
            items: items
        )
    }
}

extension ListingsItemDTO {
    static func mocked(
        id: Int = 1,
        categoryID: Int = 10,
        title: String = "Title",
        description: String = "Description",
        price: Int = 100,
        creationDate: String = "2019-11-05T20:03:05Z",
        isUrgent: Bool = false,
        imagesURL: ImagesURLDTO = .mocked()
    ) -> ListingsItemDTO {
        ListingsItemDTO(
            id: id,
            categoryID: categoryID,
            title: title,
            description: description,
            price: price,
            creationDate: creationDate,
            isUrgent: isUrgent,
            imagesURL: imagesURL
        )
    }
}

extension ImagesURLDTO {
    static func mocked(
        small: String = "/small.jpg",
        thumb: String = "/thumb.jpg"
    ) -> ImagesURLDTO {
        ImagesURLDTO(small: small, thumb: thumb)
    }
}
