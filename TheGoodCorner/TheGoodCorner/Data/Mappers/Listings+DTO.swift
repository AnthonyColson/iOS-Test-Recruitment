//
//  Listings+DTO.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Foundation

extension ListingsPage {
    init(from dto: ListingsDTO) {
        self.init(
            total: dto.total,
            page: dto.page,
            limit: dto.limit,
            hasMore: dto.hasMore,
            items: dto.items.compactMap { try? ListingsItem(from: $0) }
        )
    }
}

extension ListingsItem {
    init(from dto: ListingsItemDTO) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: dto.creationDate) else {
            throw NetworkError.APIResponse.dtoMismatch
        }
        
        self.init(
            id: dto.id,
            categoryID: dto.categoryID,
            title: dto.title,
            description: dto.description,
            price: dto.price,
            creationDate: date,
            isUrgent: dto.isUrgent,
            imagesURL: ImagesURL(
                small: URL(string: dto.imagesURL.small),
                thumb: URL(string: dto.imagesURL.thumb)
            ),
        )
    }
}
