import SwiftUI

@main
struct TheGoodCornerApp: App {

    // Composition Root — the factory is created once at app launch and
    // propagated to every screen via the environment.
    @StateObject private var factory: ViewModelFactory = .live()

    var body: some Scene {
        WindowGroup {
            RouterView(Router<AppRoute>()) {
                DashboardViewLoader()
            }
            .environmentObject(factory)
        }
    }
}
