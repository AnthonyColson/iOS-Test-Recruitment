//
//  Listings.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

// MARK: - Listings
struct Listings {
    let total, page, limit: Int
    let hasMore: Bool
    let items: [Item]
    
    init(from dto: ListingsDTO) {
        self.total = dto.total
        self.page = dto.page
        self.limit = dto.limit
        self.hasMore = dto.hasMore
        self.items = dto.items.map { Item(from: $0) }
    }
}

// MARK: - Item
struct Item: Equatable, Hashable, Identifiable {
    let id, categoryID: Int
    let title, description: String
    let price: Int
    let creationDate: Date
    let isUrgent: Bool
    let imagesURL: ImagesURL
    
    init(from dto: ItemDTO) {
        self.id = dto.id
        self.categoryID = dto.categoryID
        self.title = dto.title
        self.description = dto.description
        self.price = dto.price
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        self.creationDate = dateFormatter.date(from: dto.creationDate) ?? Date()
        self.isUrgent = dto.isUrgent
        self.imagesURL = ImagesURL(from: dto.imagesURL)
    }
}

// MARK: - ImagesURLDTO
struct ImagesURL: Equatable, Hashable {
    let small, thumb: String
    
    init(from dto: ImagesURLDTO) {
        self.small = dto.small
        self.thumb = dto.thumb
    }
}
