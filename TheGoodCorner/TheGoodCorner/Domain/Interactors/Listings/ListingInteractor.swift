//
//  ListingInteractor.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import Foundation

protocol ListingsInteractor: Sendable {
    func getListings(pagination:  (page: Int, limit: Int)?, query: String?) async throws -> Listings
    func getCategories() async throws -> Categories
}
