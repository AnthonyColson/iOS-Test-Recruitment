//
//  DesignSystemShowcaseView.swift
//  TheGoodCorner
//
//  Created by ANTHONY GIUNTA on 21/05/2026.
//

import SwiftUI

/// Visual reference for every atomic element of the design system.
///
/// Useful as a living style guide and as a manual visual-regression
/// surface (toggle the preview between light and dark to check that
/// every token adapts correctly).
public struct DesignSystemShowcaseView: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                header
                spacingSection
                borderRadiusSection
                borderWidthSection
                colorSection
                typographySection
            }
            .padding(Spacing.l)
        }
        .background(AppColor.background.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Design System")
                .font(Typo.largeTitle)
                .foregroundStyle(AppColor.textPrimary)
            Text("Atomic elements showcase")
                .font(Typo.callout)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    // MARK: - Spacing

    private var spacingSection: some View {
        ShowcaseSection(title: "Spacing") {
            VStack(alignment: .leading, spacing: Spacing.s) {
                SpacingRow(label: "xxs · 2",  value: Spacing.xxs)
                SpacingRow(label: "xs · 4",   value: Spacing.xs)
                SpacingRow(label: "s · 8",    value: Spacing.s)
                SpacingRow(label: "m · 16",   value: Spacing.m)
                SpacingRow(label: "l · 24",   value: Spacing.l)
                SpacingRow(label: "xl · 32",  value: Spacing.xl)
                SpacingRow(label: "xxl · 48", value: Spacing.xxl)
                SpacingRow(label: "xxxl · 64", value: Spacing.xxxl)
            }
        }
    }

    // MARK: - Border radius

    private var borderRadiusSection: some View {
        ShowcaseSection(title: "Border radius") {
            HStack(spacing: Spacing.m) {
                RadiusSwatch(label: "xs",   radius: BorderRadius.xs)
                RadiusSwatch(label: "s",    radius: BorderRadius.s)
                RadiusSwatch(label: "m",    radius: BorderRadius.m)
                RadiusSwatch(label: "l",    radius: BorderRadius.l)
                RadiusSwatch(label: "xl",   radius: BorderRadius.xl)
                RadiusSwatch(label: "pill", radius: BorderRadius.pill)
            }
        }
    }

    // MARK: - Border width

    private var borderWidthSection: some View {
        ShowcaseSection(title: "Border width") {
            VStack(alignment: .leading, spacing: Spacing.s) {
                WidthRow(label: "hairline · 0.5", width: BorderWidth.hairline)
                WidthRow(label: "thin · 1",       width: BorderWidth.thin)
                WidthRow(label: "regular · 2",    width: BorderWidth.regular)
                WidthRow(label: "thick · 4",      width: BorderWidth.thick)
            }
        }
    }

    // MARK: - Color

    private var colorSection: some View {
        ShowcaseSection(title: "Colors") {
            VStack(alignment: .leading, spacing: Spacing.m) {
                colorGroup(title: "Backgrounds", swatches: [
                    ("background",   AppColor.background),
                    ("surface",      AppColor.surface),
                    ("surfaceMuted", AppColor.surfaceMuted)
                ])
                colorGroup(title: "Text", swatches: [
                    ("textPrimary",   AppColor.textPrimary),
                    ("textSecondary", AppColor.textSecondary),
                    ("textDisabled",  AppColor.textDisabled)
                ])
                colorGroup(title: "Brand", swatches: [
                    ("primary", AppColor.primary),
                    ("accent",  AppColor.accent)
                ])
                colorGroup(title: "Semantic", swatches: [
                    ("success", AppColor.success),
                    ("warning", AppColor.warning),
                    ("error",   AppColor.error),
                    ("info",    AppColor.info)
                ])
                colorGroup(title: "Borders", swatches: [
                    ("border",         AppColor.border),
                    ("borderEmphasis", AppColor.borderEmphasis)
                ])
            }
        }
    }

    private func colorGroup(title: String, swatches: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(Typo.caption)
                .foregroundStyle(AppColor.textSecondary)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.s), count: 2),
                spacing: Spacing.s
            ) {
                ForEach(swatches, id: \.0) { name, color in
                    ColorSwatch(name: name, color: color)
                }
            }
        }
    }

    // MARK: - Typography

    private var typographySection: some View {
        ShowcaseSection(title: "Typography") {
            VStack(alignment: .leading, spacing: Spacing.s) {
                TypoRow(label: "display",    font: Typo.display)
                TypoRow(label: "largeTitle", font: Typo.largeTitle)
                TypoRow(label: "title1",     font: Typo.title1)
                TypoRow(label: "title2",     font: Typo.title2)
                TypoRow(label: "title3",     font: Typo.title3)
                TypoRow(label: "callout",    font: Typo.callout)
                TypoRow(label: "bodyBold",   font: Typo.bodyBold)
                TypoRow(label: "body",       font: Typo.body)
                TypoRow(label: "bodySmall",  font: Typo.bodySmall)
                TypoRow(label: "footnote",   font: Typo.footnote)
                TypoRow(label: "caption",    font: Typo.caption)
                TypoRow(label: "overline",   font: Typo.overline)
            }
        }
    }
}

// MARK: - Section wrapper

private struct ShowcaseSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(title)
                .font(Typo.title2)
                .foregroundStyle(AppColor.textPrimary)
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.m)
                .background(
                    RoundedRectangle(cornerRadius: BorderRadius.m)
                        .fill(AppColor.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BorderRadius.m)
                        .stroke(AppColor.border, lineWidth: BorderWidth.thin)
                )
        }
    }
}

// MARK: - Spacing row

private struct SpacingRow: View {
    let label: String
    let value: CGFloat

    var body: some View {
        HStack(spacing: Spacing.m) {
            Text(label)
                .font(Typo.caption)
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: 80, alignment: .leading)
            RoundedRectangle(cornerRadius: BorderRadius.xs)
                .fill(AppColor.primary)
                .frame(width: value, height: 16)
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Radius swatch

private struct RadiusSwatch: View {
    let label: String
    let radius: CGFloat

    var body: some View {
        VStack(spacing: Spacing.xs) {
            RoundedRectangle(cornerRadius: min(radius, 32))
                .fill(AppColor.accent)
                .frame(width: 48, height: 48)
            Text(label)
                .font(Typo.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

// MARK: - Width row

private struct WidthRow: View {
    let label: String
    let width: CGFloat

    var body: some View {
        HStack(spacing: Spacing.m) {
            Text(label)
                .font(Typo.caption)
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: 120, alignment: .leading)
            RoundedRectangle(cornerRadius: BorderRadius.xs)
                .stroke(AppColor.textPrimary, lineWidth: width)
                .frame(height: 32)
        }
    }
}

// MARK: - Color swatch

private struct ColorSwatch: View {
    let name: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.s) {
            RoundedRectangle(cornerRadius: BorderRadius.s)
                .fill(color)
                .frame(width: 36, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: BorderRadius.s)
                        .stroke(AppColor.border, lineWidth: BorderWidth.hairline)
                )
            Text(name)
                .font(Typo.footnote)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Typography row

private struct TypoRow: View {
    let label: String
    let font: Font

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.m) {
            Text(label)
                .font(Typo.caption)
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: 88, alignment: .leading)
            Text("The quick brown fox")
                .font(font)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Previews

#Preview("Light") {
    DesignSystemShowcaseView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    DesignSystemShowcaseView()
        .preferredColorScheme(.dark)
}
