
import SwiftUI

struct AuthenticationViews: View {

    @AppStorage("hasAccount") private var hasAccount = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @State private var showSignup = false

    var body: some View {

        Group {
            if isLoggedIn {

                MainTabView()

            } else if showSignup {

                SignupView {
                    showSignup = false
                }

            } else {

                LoginView {
                    showSignup = true
                }
            }
        }
    }
}

