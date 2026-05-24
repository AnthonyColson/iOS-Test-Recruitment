//
//  ImageComponentViewModel.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 24/05/2026.
//

import Foundation
import SwiftUI
import Combine

enum ImageMemoryCache {
    private static let cache = NSCache<NSURL, UIImage>()
    static func image(for url: URL) -> UIImage? { cache.object(forKey: url as NSURL) }
    static func set(_ image: UIImage, for url: URL) { cache.setObject(image, forKey: url as NSURL) }
}

final class ImageComponentViewModel: ObservableObject {

    enum Phase {
        case empty
        case success(UIImage)
        case failure(Error)
    }

    @Published private(set) var phase: Phase = .empty

    private var task: Task<Void, Never>?

    @MainActor
    func load(url: URL?) {
        task?.cancel()
        guard let url else { phase = .empty; return }

        // 1. Cache hit → instant, pas de spinner.
        if let cached = ImageMemoryCache.image(for: url) {
            phase = .success(cached)
            return
        }

        phase = .empty
        task = Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                try Task.checkCancellation()
                guard let image = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }
                ImageMemoryCache.set(image, for: url)
                self?.phase = .success(image)
            } catch is CancellationError {
                // cellule recyclée, on ne fait rien
            } catch {
                self?.phase = .failure(error)
            }
        }
    }

    func cancel() { task?.cancel() }
}
