//
//  ListingCardComponent.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI


public struct ListingCardComponent: View {

    // MARK: - Dependencies

    private let item: ListingCardItem

    @ScaledMetric(relativeTo: .body)     private var titleSize:    CGFloat = TypoSize.body
    @ScaledMetric(relativeTo: .callout)  private var priceSize:    CGFloat = TypoSize.callout
    @ScaledMetric(relativeTo: .caption)  private var captionSize:  CGFloat = TypoSize.caption
    @ScaledMetric(relativeTo: .caption2) private var overlineSize: CGFloat = TypoSize.overline

    // MARK: - Init

    public init(item: ListingCardItem) {
        self.item = item
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            ImageComponent(
                url: item.imagesURL.small,
                cornerRadius: BorderRadius.s
            )
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topLeading) {
                if item.shouldShowUrgentBadge {
                    urgentBadge
                        .padding(Spacing.s)
                }
            }

            Text(item.displayedTitle)
                .font(.system(size: titleSize, weight: TypoWeight.semibold))
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)

            Text(item.formattedPrice)
                .font(.system(size: priceSize, weight: TypoWeight.medium))
                .foregroundStyle(AppColor.primary)

            if let formattedCategory = item.formattedCategory {
                Text(formattedCategory)
                    .font(.system(size: captionSize))
                    .foregroundStyle(AppColor.textSecondary)
            }
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
        // Cap Dynamic Type so the card stays usable at accessibility sizes
        // without breaking the two-up grid layout.
        .dynamicTypeSize(.xSmall ... .accessibility2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.accessibilityDescription)
    }

    // MARK: - Urgent badge

    private var urgentBadge: some View {
        Text("URGENT")
            .font(.system(size: overlineSize, weight: TypoWeight.bold))
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
                item: ListingCardItem(
                    id: 100,
                    imagesURL: ImagesURL(small: nil, thumb: URL(string: "https://picsum.photos/seed/a/400")),
                    title: "Vintage leather armchair in excellent condition",
                    description: "Vintage leather armchair in excellent condition Vintage leather armchair in excellent condition Vintage leather armchair in excellent condition",
                    price: 249,
                    category: "house",
                    isUrgent: true
                )
            )
            ListingCardComponent(
                item: ListingCardItem(
                    id: 101,
                    imagesURL: ImagesURL(small: URL(string: "https://picsum.photos/seed/a/400"), thumb: nil),
                    title: "Bicycle",
                    description: nil,
                    price: 120,
                    category: "work",
                    isUrgent: false
                )
            )
        }
        .padding(Spacing.m)
    }
    .background(AppColor.background)
}
