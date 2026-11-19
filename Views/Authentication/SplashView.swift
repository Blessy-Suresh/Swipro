
import SwiftUI

struct SplashView: View {

    var onFinish: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.91, blue: 1.0)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)

                Text("Your Personal Meal Planner")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onFinish()
            }
        }
    }
}
