import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var router: Router<AppRoute>
    @StateObject var viewModel: DashboardViewModel

    @State private var currentReloadTask: Task<Void, Never>?

    init(viewModel: DashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: Spacing.l) {
            TextField(String(), text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, Spacing.m)
            categoriesList
            gridView
        }
        .task { [weak viewModel] in
            await viewModel?.onAppear()
        }
        .onChange(of: viewModel.debouncedText) { [weak viewModel] _ in
            guard let viewModel else { return }
            
            currentReloadTask?.cancel()
            
            currentReloadTask = Task {
                await viewModel.searchItemsFromText()
            }
        }
        .toolbar {
#if DEBUG
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.navigate(to: .showcase, mode: .sheet)
                } label: {
                    Image(systemName: "paintpalette")
                }
                .accessibilityLabel("Open design system showcase")
            }
#endif
        }
    }
    
    @ViewBuilder
    var categoriesList: some View {
        switch viewModel.categoriesState {
        case .loading:
            VStack(alignment: .center) {
                Spacer()
                ProgressView()
                Spacer()
            }
        case .success:
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(viewModel.allCategories.sorted(by: >), id: \.key) { key, value in
                        Text(value)
                            .font(Typo.callout)
                            .foregroundColor(AppColor.textPrimary)
                            .padding(.horizontal, Spacing.m)
                            .padding(.vertical, Spacing.s)
                            .background(
                                RoundedRectangle(cornerRadius: BorderRadius.m)
                                    .foregroundColor(key == viewModel.selectedCategory?.id ? AppColor.borderEmphasis : AppColor.border)
                            )
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(value)
                            .accessibilityValue(
                                key == viewModel.selectedCategory?.id
                                    ? Text("Selected")
                                    : Text("Not selected")
                            )
                            .accessibilityAddTraits(
                                key == viewModel.selectedCategory?.id ? [.isButton, .isSelected] : [.isButton]
                            )
                            .accessibilityHint("Double tap to filter listings by this category")
                            .dynamicTypeSize(...DynamicTypeSize.medium)
                            .accessibilityShowsLargeContentViewer {
                                Text(value)
                                    .font(Typo.title1)
                            }
                            .onTapGesture { [weak viewModel] in
                                Task {
                                    await viewModel?.selectCategory(CategoriesElement(id: key, name: value))
                                }
                            }
                    }
                }
                .padding(.horizontal, Spacing.m)
            }
            .frame(maxHeight: 40)

        case .error:
            VStack(alignment: .center) {
                Text("There is an error on categories")
                    .font(Typo.callout)
                
                Text("Retry")
                    .font(Typo.callout)
                    .onTapGesture {
                        Task { [weak viewModel] in
                            await viewModel?.retry()
                        }
                    }
            }
            .frame(maxHeight: 40)
        }
    }
    
    @ViewBuilder
    var gridView: some View {
        switch viewModel.listingState {
        case .loading:
            VStack(alignment: .center) {
                Spacer()
                ProgressView()
                Spacer()
            }
        case .empty:
            VStack(alignment: .center) {
                Spacer()
                Text("The list is empty")
                    .font(Typo.callout)
                Spacer()
            }
        case .success:
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: Spacing.m),
                        GridItem(.flexible(), spacing: Spacing.m)
                    ],
                    spacing: Spacing.m
                ) {
                    ForEach(Array(viewModel.listingCardItems.enumerated()), id: \.element.id) { index, item in
                        ListingCardComponent(item: item)
                            .onTapGesture {
                                router.navigate(to: .details(item: item))
                            }
                            .onAppear { [weak viewModel] in
                                guard let viewModel else { return }
                                if index % 2 == 0, index >= viewModel.listingCardItems.count - 4 {
                                    currentReloadTask?.cancel()
                                    
                                    currentReloadTask = Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal, Spacing.m)
                
                Text("End of list")
                    .font(Typo.callout)
                    .padding(.top, Spacing.m)
                
                Spacer()
            }
        case .error:
            VStack(alignment: .center) {
                
                Spacer()
                
                Text("There is an error on listing")
                    .font(Typo.callout)
                
                Text("Retry")
                    .font(Typo.callout)
                    .onTapGesture {
                        Task { [weak viewModel] in
                            await viewModel?.retry()
                        }
                    }
                
                Spacer()
            }
        }
    }
}

struct DashboardViewLoader: View {
    @EnvironmentObject private var factory: ViewModelFactory

    var body: some View {
        DashboardView(viewModel: factory.makeDashboardViewModel())
    }
}

#Preview {
    DashboardViewLoader()
        .environmentObject(ViewModelFactory.live())
        .environmentObject(Router<AppRoute>())
}
