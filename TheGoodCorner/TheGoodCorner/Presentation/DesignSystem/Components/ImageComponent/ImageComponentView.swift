//
//  ImageComponent.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI

public struct ImageComponentView: View {
    
    @StateObject private var loader = ImageComponentViewModel()

    // MARK: - Inputs

    private let url: URL?
    private let cornerRadius: CGFloat

    // MARK: - State

    @State private var reloadID = UUID()

    // MARK: - Init

    public init(
        url: URL?,
        cornerRadius: CGFloat = BorderRadius.s
    ) {
        self.url = url
        self.cornerRadius = cornerRadius
    }

    // MARK: - Body
    
    public var body: some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .task(id: "\(url?.absoluteString ?? "")-\(reloadID)") {
                loader.load(url: url)
            }
            .onDisappear { loader.cancel() }
    }

    // MARK: - Phases

    @ViewBuilder
    private var content: some View {
        switch loader.phase {
        case .empty:
            emptyView
        case .success(let uiImage):
            Image(uiImage: uiImage)
                .resizable()
        case .failure(let error):
            errorView(error: error)
        }
    }

    // MARK: - Placeholder (missing image)

    private var emptyView: some View {
        ZStack {
            AppColor.surfaceMuted
            Image(systemName: "photo")
                .font(.system(size: 32))
                .foregroundStyle(AppColor.textDisabled)
                .accessibilityHidden(true)
        }
        .accessibilityLabel("No image available")
    }

    // MARK: - Error

    private func errorView(error: Error?) -> some View {
        ZStack {
            AppColor.surfaceMuted
            VStack(spacing: Spacing.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppColor.error)

                Text("Unable to load image")
                    .font(Typo.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)

                Button {
                    reloadID = UUID()
                } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                        .font(Typo.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(AppColor.primary)
                .accessibilityLabel("Retry loading image")
            }
            .padding(Spacing.s)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            error.map { String(localized: "Image failed to load: \($0.localizedDescription)") }
                ?? String(localized: "Image failed to load")
        )
    }
}

// MARK: - Previews

#Preview("Success") {
    ImageComponentView(
        url: URL(string: "https://picsum.photos/seed/goodcorner/400/400")
    )
    .frame(width: 200, height: 200)
    .padding()
}

#Preview("Failure") {
    ImageComponentView(
        url: URL(string: "https://this-url-does-not-resolve.invalid/image.jpg")
    )
    .frame(width: 200, height: 200)
    .padding()
}

#Preview("Nil URL") {
    ImageComponentView(url: nil)
        .frame(width: 200, height: 200)
        .padding()
}
