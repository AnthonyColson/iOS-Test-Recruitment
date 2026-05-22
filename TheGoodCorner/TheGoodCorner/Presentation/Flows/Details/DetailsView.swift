//
//  DetailsView.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 22/05/2026.
//

import SwiftUI

struct DetailsView: View {

    // MARK: - Dependencies

    @EnvironmentObject private var router: Router<AppRoute>
    private var viewModel: DetailsViewModel

    // MARK: - Dynamic Type — anchored to Apple text styles

    @ScaledMetric(relativeTo: .title2) private var titleSize: CGFloat = TypoSize.title2
    @ScaledMetric(relativeTo: .title3) private var priceSize: CGFloat = TypoSize.title1
    @ScaledMetric(relativeTo: .body) private var categorySize: CGFloat = TypoSize.body
    @ScaledMetric(relativeTo: .callout) private var sectionHeaderSize: CGFloat = TypoSize.callout
    @ScaledMetric(relativeTo: .caption) private var badgeSize: CGFloat = TypoSize.caption

    // MARK: - Init

    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                heroImage
                content
            }
            .padding(.bottom, Spacing.l)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("Page Detail")
        .navigationBarTitleDisplayMode(.inline)
        .dynamicTypeSize(.xSmall ... .accessibility2)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Hero image

    private var heroImage: some View {
        ImageComponent(
            url: viewModel.imageURL,
            cornerRadius: BorderRadius.s
        )
        .aspectRatio(1, contentMode: .fit)
        .overlay(alignment: .topLeading) {
            if viewModel.isUrgent {
                urgentBadge
                    .padding(Spacing.m)
            }
        }
        .padding(.horizontal, Spacing.m)
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(viewModel.title)
                .font(.system(size: titleSize, weight: .bold))
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.leading)
                .accessibilityAddTraits(.isHeader)

            Text(viewModel.formattedPrice)
                .font(.system(size: priceSize, weight: .semibold))
                .foregroundStyle(AppColor.primary)

            if let category = viewModel.formattedCategory {
                Text(category)
                    .font(.system(size: categorySize))
                    .foregroundStyle(AppColor.textSecondary)
            }

            if let description = viewModel.description {
                descriptionSection(description)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.m)
    }

    // MARK: - Description section

    private func descriptionSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Description")
                .font(.system(size: sectionHeaderSize, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text(text)
                .font(.system(size: categorySize))
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, Spacing.s)
    }

    // MARK: - Urgent badge

    private var urgentBadge: some View {
        Text("URGENT")
            .font(.system(size: badgeSize, weight: .bold))
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

#Preview {
    DetailsView(
        viewModel: DetailsViewModel(
            item: ListingCardIViewModel(
                id: 1,
                imagesURL: ImagesURL(small: nil, thumb: URL(string: "https://picsum.photos/seed/a/400")),
                title: "Vintage leather armchair in excellent condition",
                description: "Vintage leather armchair in excellent condition Vintage leather armchair in excellent condition Vintage leather armchair in excellent condition",
                price: 249,
                category: "Meuble",
                isUrgent: true
            )
        )
    )
}
