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
            searchfield
            categoriesList
            gridView
        }
        .onAppear {
            currentReloadTask?.cancel()
            
            currentReloadTask = Task {
                await viewModel.onAppear()
            }
        }
        .onDisappear { currentReloadTask?.cancel() }
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
    
    var searchfield: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .frame(width: 20, height: 20)
                .accessibilityHidden(true)
            TextField("An iPhone", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .accessibilityHint("Search your object")
                .accessibilityAddTraits(.isSearchField)
                
        }
        .dynamicTypeSize(...DynamicTypeSize.xLarge)
        .padding(.horizontal, Spacing.m)
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
                            .onTapGesture {
                                currentReloadTask?.cancel()
                                
                                currentReloadTask = Task {
                                    await viewModel.selectCategory(CategoriesElement(id: key, name: value))
                                }
                            }
                    }
                }
                .padding(.horizontal, Spacing.m)
            }
            .frame(maxHeight: 40)

        case .error:
            VStack(alignment: .center, spacing: Spacing.s) {
                Text("There is an error on categories")
                    .multilineTextAlignment(.center)
                    .font(Typo.callout)
                
                Button("Retry") {
                    Task {
                        await viewModel.retry()
                    }
                }
                .font(Typo.callout)
                .buttonStyle(.bordered)
            }
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
            VStack {
                List {
                    ForEach(Array(stride(from: 0, to: viewModel.listingCardItems.count, by: 2)), id: \.self) { index in
                        HStack {
                            ListingCardComponent(item: viewModel.listingCardItems[index])
                                .onTapGesture {
                                    router.navigate(to: .details(item: viewModel.listingCardItems[index]))
                                }
                            if index + 1 < viewModel.listingCardItems.count {
                                ListingCardComponent(item: viewModel.listingCardItems[index + 1])
                                    .onTapGesture {
                                        router.navigate(to: .details(item: viewModel.listingCardItems[index + 1]))
                                    }
                            } else {
                                Color.clear  // garde l'alignement quand le nombre est impair
                            }
                        }
                        .onAppear {
                            if index >= viewModel.listingCardItems.count - 4 {
                                currentReloadTask?.cancel()
                                
                                currentReloadTask = Task {
                                    await viewModel.loadNextPage()
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    
                    Text("End of list")
                        .font(Typo.callout)
                        .padding(.top, Spacing.m)
                        .listRowSeparator(.hidden)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .listStyle(.plain)
            }
        case .error:
            VStack(alignment: .center, spacing: Spacing.l) {
                Spacer()
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .accessibilityHidden(true)
                
                Text("There is an error on listing")
                    .multilineTextAlignment(.center)
                    .font(Typo.callout)
                
                
                Button("Retry") {
                    Task {
                        await viewModel.retry()
                    }
                }
                .font(Typo.callout)
                .buttonStyle(.bordered)
                
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
