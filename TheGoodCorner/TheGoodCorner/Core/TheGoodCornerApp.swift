import SwiftUI

@main
struct TheGoodCornerApp: App {
    var body: some Scene {
        WindowGroup {
            RouterView(Router<AppRoute>()) {
                DashbaordView()
            }
        }
    }
}
