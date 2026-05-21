import SwiftUI

struct ContentView: View {
    #if DEBUG
    @State private var isShowcasePresented = false
    #endif

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
                        isShowcasePresented = true
                    } label: {
                        Image(systemName: "paintpalette")
                    }
                    .accessibilityLabel("Open design system showcase")
                }
                #endif
            }
            #if DEBUG
            .sheet(isPresented: $isShowcasePresented) {
                DesignSystemShowcaseView()
            }
            #endif
        }
    }
}

#Preview {
    ContentView()
}
