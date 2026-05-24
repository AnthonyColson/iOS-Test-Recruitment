//
//  Array+Helpers.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import Foundation

extension Array where Element: Identifiable {
    mutating func appendUnique(contentsOf other: [Element]) {
        var seen = Set(self.map(\.id))
        for element in other where seen.insert(element.id).inserted {
            append(element)
        }
    }
}
