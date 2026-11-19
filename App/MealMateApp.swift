
import SwiftUI

@main
struct MealMateApp: App {

    init() {
        // Require login again whenever the app is reopened.
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinator()
        }
    }
}

