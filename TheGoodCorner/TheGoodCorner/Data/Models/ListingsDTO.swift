//
//  ListingsDTO.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

// MARK: - ListingsDTO
struct ListingsDTO: Decodable {
    let total, page, limit: Int
    let hasMore: Bool
    let items: [ItemDTO]

    enum CodingKeys: String, CodingKey {
        case total, page, limit
        case hasMore = "has_more"
        case items
    }
}

// MARK: - ItemDTO
struct ItemDTO: Decodable {
    let id, categoryID: Int
    let title, description: String
    let price: Int
    let creationDate: String
    let isUrgent: Bool
    let imagesURL: ImagesURLDTO

    enum CodingKeys: String, CodingKey {
        case id
        case categoryID = "category_id"
        case title, description, price
        case creationDate = "creation_date"
        case isUrgent = "is_urgent"
        case imagesURL = "images_url"
    }
}

// MARK: - ImagesURLDTO
struct ImagesURLDTO: Decodable {
    let small, thumb: String
    
    enum CodingKeys: String, CodingKey {
           case small = "small"
           case thumb = "thumb"
       }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let smallPath = try c.decodeIfPresent(String.self, forKey: .small)
        let thumbPath = try c.decodeIfPresent(String.self, forKey: .thumb)
        if let smallPath {
            self.small = APIEndpoints.baseURLString + smallPath
        } else {
            self.small = String()
        }
        if let thumbPath {
            self.thumb = APIEndpoints.baseURLString + thumbPath
        } else {
            self.thumb = String()
        }
    }
}

