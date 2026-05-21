import SwiftUI

struct DashbaordView: View {
    @EnvironmentObject private var router: Router<AppRoute>

    var body: some View {
        
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
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
    }
}

#Preview {
    DashbaordView()
}
