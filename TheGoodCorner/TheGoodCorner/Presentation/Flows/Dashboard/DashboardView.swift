import SwiftUI

struct DashbaordView: View {
    @EnvironmentObject private var router: Router<AppRoute>
    @StateObject var viewModel: DashbaordViewModel
    
    @State private var currentReloadTask: Task<Void, Never>?
    
    init() {
        let viewModel = ViewModelFactory.makeDashboardViewModel()
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.l) {
               categoriesList
               gridView
            }
        }
        .onAppear {
            Task { [weak viewModel] in
                await viewModel?.loadData()
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
                            .dynamicTypeSize(...DynamicTypeSize.medium)
                            .accessibilityShowsLargeContentViewer {
                                Text(value)
                                    .font(Typo.title1)
                            }
                            .onTapGesture { [weak viewModel] in
                                guard let viewModel else { return }
                                
                                currentReloadTask?.cancel()
                                
                                currentReloadTask = Task {
                                    await viewModel.tapOnCategory(with: CategoriesElement(id: key, name: value))
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
                            await viewModel?.loadData()
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
        case .success:
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: Spacing.m),
                        GridItem(.flexible(), spacing: Spacing.m)
                    ],
                    spacing: Spacing.m
                ) {
                    ForEach(viewModel.listingCardItems, id: \.self) { item in
                        ListingCardComponent(item: item)
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
                            await viewModel?.loadData()
                        }
                    }
                
                Spacer()
            }
        }
    }
}

#Preview {
    DashbaordView()
}
