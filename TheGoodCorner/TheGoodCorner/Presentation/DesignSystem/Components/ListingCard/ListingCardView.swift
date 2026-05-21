//
//  ListingCardComponent.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI


public struct ListingCardComponent: View {

    // MARK: - Dependencies

    private let viewModel: ListingCardViewModel

    // MARK: - Init

    public init(viewModel: ListingCardViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            ImageComponent(
                url: viewModel.imageURL,
                contentMode: .fill,
                cornerRadius: BorderRadius.s
            )
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topLeading) {
                if viewModel.shouldShowUrgentBadge {
                    urgentBadge
                        .padding(Spacing.s)
                }
            }

            Text(viewModel.displayedTitle)
                .font(Typo.bodyBold)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)

            Text(viewModel.formattedPrice)
                .font(Typo.callout)
                .foregroundStyle(AppColor.primary)

            Text(viewModel.formattedDate)
                .font(Typo.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(Spacing.s)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.m)
                .fill(AppColor.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BorderRadius.m)
                .stroke(AppColor.border, lineWidth: BorderWidth.hairline)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.accessibilityDescription)
    }

    // MARK: - Urgent badge

    private var urgentBadge: some View {
        Text("URGENT")
            .font(Typo.overline)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.xxs)
            .background(
                Capsule()
                    .fill(AppColor.error)
            )
            .accessibilityLabel("Urgent")
    }
}

// MARK: - Previews

#Preview("Two-up grid") {
    ScrollView {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Spacing.m),
                GridItem(.flexible(), spacing: Spacing.m)
            ],
            spacing: Spacing.m
        ) {
            ListingCardComponent(
                viewModel: ListingCardViewModel(
                    imageURL: URL(string: "https://picsum.photos/seed/a/400"),
                    title: "Vintage leather armchair in excellent condition",
                    price: 249.90,
                    date: Date(),
                    isUrgent: true
                )
            )
            ListingCardComponent(
                viewModel: ListingCardViewModel(
                    imageURL: URL(string: "https://picsum.photos/seed/b/400"),
                    title: "Bicycle",
                    price: 120,
                    date: Date().addingTimeInterval(-86_400 * 3)
                )
            )
            ListingCardComponent(
                viewModel: ListingCardViewModel(
                    imageURL: URL(string: "https://picsum.photos/seed/c/400"),
                    title: "Macbook Pro 14\" M2 - barely used, original box included",
                    price: 1450,
                    date: Date().addingTimeInterval(-86_400 * 10),
                    isUrgent: true
                )
            )
            ListingCardComponent(
                viewModel: ListingCardViewModel(
                    imageURL: nil,
                    title: "Wooden coffee table",
                    price: 60,
                    date: Date().addingTimeInterval(-86_400 * 30)
                )
            )
        }
        .padding(Spacing.m)
    }
    .background(AppColor.background)
}
