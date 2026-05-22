//
//  ListingsPage.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

// MARK: - ListingsPage
struct ListingsPage {
    let total, page, limit: Int
    let hasMore: Bool
    let items: [ListingsItem]
}

// MARK: - ListingsItem
struct ListingsItem: Equatable, Hashable, Identifiable {
    let id, categoryID: Int
    let title, description: String
    let price: Int
    let creationDate: Date
    let isUrgent: Bool
    let imagesURL: ImagesURL
}

// MARK: - ImagesURL
public struct ImagesURL: Equatable, Hashable {
    public let small: URL?
    public let thumb: URL?
}
