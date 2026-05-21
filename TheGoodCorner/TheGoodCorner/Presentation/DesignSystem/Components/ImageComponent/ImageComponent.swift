//
//  ImageComponent.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI

public struct ImageComponent: View {

    // MARK: - Inputs

    private let url: URL?
    private let contentMode: ContentMode
    private let cornerRadius: CGFloat

    // MARK: - State

    @State private var reloadID = UUID()

    // MARK: - Init

    public init(
        url: URL?,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = BorderRadius.s
    ) {
        self.url = url
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
    }

    // MARK: - Body

    public var body: some View {
        AsyncImage(
            url: url,
            transaction: Transaction(animation: .easeInOut(duration: 0.2))
        ) { phase in
            content(for: phase)
        }
        .id(reloadID)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    // MARK: - Phases

    @ViewBuilder
    private func content(for phase: AsyncImagePhase) -> some View {
        switch phase {
        case .empty:
            loadingView
        case .success(let image):
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        case .failure(let error):
            errorView(error: error)
        @unknown default:
            errorView(error: nil)
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        ZStack {
            AppColor.surfaceMuted
            ProgressView()
                .tint(AppColor.textSecondary)
        }
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
            error.map { "Image failed to load: \($0.localizedDescription)" }
                ?? "Image failed to load"
        )
    }
}

// MARK: - Previews

#Preview("Success") {
    ImageComponent(
        url: URL(string: "https://picsum.photos/seed/goodcorner/400/400")
    )
    .frame(width: 200, height: 200)
    .padding()
}

#Preview("Failure") {
    ImageComponent(
        url: URL(string: "https://this-url-does-not-resolve.invalid/image.jpg")
    )
    .frame(width: 200, height: 200)
    .padding()
}

#Preview("Nil URL") {
    ImageComponent(url: nil)
        .frame(width: 200, height: 200)
        .padding()
}
