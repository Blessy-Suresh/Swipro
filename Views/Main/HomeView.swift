
import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel = HomeViewModel()

    var onOpenMeals: () -> Void
    var onAddMeal: () -> Void

    private let purple = Color(
        red: 0.43,
        green: 0.32,
        blue: 0.60
    )

    private let lavender = Color(
        red: 0.95,
        green: 0.92,
        blue: 0.98
    )

    private let backgroundColor = Color(
        red: 0.98,
        green: 0.97,
        blue: 0.99
    )

    var body: some View {

        ZStack {

            backgroundColor
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 24) {

                    headerSection

                    weeklyOverviewSection

                    summarySection

                    progressSection

                    upcomingMealSection

                    quickActionsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Header

    private var headerSection: some View {

        HStack {

            VStack(alignment: .leading, spacing: 6) {

                Text("Good to see you!")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(Color.black.opacity(0.85))

                Text("Your weekly meals, beautifully organized.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 13))
        }
    }

    // MARK: - Weekly Overview

    private var weeklyOverviewSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack {

                Text("Weekly Overview")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                Text(viewModel.weekDescription)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(purple)
            }

            HStack(spacing: 12) {

                Image(systemName: "calendar")
                    .font(.system(size: 24))
                    .foregroundColor(purple)

                VStack(alignment: .leading, spacing: 4) {

                    Text("Plan your week with ease")
                        .font(.system(size: 15, weight: .semibold))

                    Text("Keep your meals organized in one place.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(16)
            .background(lavender)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Summary Cards

    private var summarySection: some View {

        VStack(alignment: .leading, spacing: 14) {

            Text("Meal Summary")
                .font(.system(size: 19, weight: .bold))

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {

                summaryCard(
                    title: "Planned Meals",
                    value: viewModel.totalPlannedMeals,
                    icon: "calendar.badge.checkmark",
                    color: purple
                )

                summaryCard(
                    title: "Cooked",
                    value: viewModel.cookedMeals,
                    icon: "checkmark.circle",
                    color: Color(red: 0.35, green: 0.55, blue: 0.43)
                )

                summaryCard(
                    title: "Pending",
                    value: viewModel.pendingMeals,
                    icon: "clock",
                    color: Color(red: 0.72, green: 0.53, blue: 0.32)
                )

                summaryCard(
                    title: "Skipped",
                    value: viewModel.skippedMeals,
                    icon: "minus.circle",
                    color: Color.gray
                )
            }
        }
    }

    private func summaryCard(
        title: String,
        value: Int,
        icon: String,
        color: Color
    ) -> some View {

        VStack(alignment: .leading, spacing: 15) {

            HStack {

                Image(systemName: icon)
                    .font(.system(size: 19))
                    .foregroundColor(color)

                Spacer()

                Text("This week")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Text("\(value)")
                .font(.system(size: 29, weight: .bold))
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 17))
        .overlay {
            RoundedRectangle(cornerRadius: 17)
                .stroke(purple.opacity(0.09), lineWidth: 1)
        }
    }

    // MARK: - Weekly Progress

    private var progressSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack {

                Text("Weekly Progress")
                    .font(.system(size: 18, weight: .bold))

                Spacer()

                Text("\(Int(viewModel.progress * 100))%")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(purple)
            }

            ProgressView(value: viewModel.progress)
                .tint(purple)
                .scaleEffect(x: 1, y: 1.5, anchor: .center)

            Text(
                "\(viewModel.cookedMeals) of \(viewModel.totalPlannedMeals) planned meals cooked"
            )
            .font(.system(size: 12))
            .foregroundColor(.secondary)
        }
        .padding(17)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }

    // MARK: - Upcoming Meal

    private var upcomingMealSection: some View {

        VStack(alignment: .leading, spacing: 13) {

            HStack {

                Text("Next Upcoming Meal")
                    .font(.system(size: 18, weight: .bold))

                Spacer()

                Button("View Meals") {
                    onOpenMeals()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(purple)
            }

            if let meal = viewModel.nextUpcomingMeal {

                VStack(alignment: .leading, spacing: 10) {

                    HStack(spacing: 13) {

                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(purple)

                        VStack(alignment: .leading, spacing: 5) {

                            Text(meal.name)
                                .font(.system(size: 16, weight: .semibold))

                            Text(meal.mealType)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)

                            Text(meal.date.formatted(
                                date: .abbreviated,
                                time: .shortened
                            ))
                            .font(.system(size: 11))
                            .foregroundColor(purple)
                        }

                        Spacer()

                        Text("Planned")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(purple)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(lavender)
                            .clipShape(Capsule())
                    }

                    Text("\(meal.calories) kcal")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 17))

            } else {

                VStack(spacing: 12) {

                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 34))
                        .foregroundColor(purple)

                    Text("No upcoming meals")
                        .font(.system(size: 15, weight: .semibold))

                    Text("Start planning your meals for this week.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button(action: onAddMeal) {

                        Label("Plan a Meal", systemImage: "plus")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 11)
                            .background(purple)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(22)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 17))
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {

        VStack(alignment: .leading, spacing: 13) {

            Text("Quick Actions")
                .font(.system(size: 18, weight: .bold))

            HStack(spacing: 12) {

                quickAction(
                    title: "Add New Meal",
                    subtitle: "Plan a meal",
                    icon: "plus.circle",
                    action: onAddMeal
                )

                quickAction(
                    title: "Weekly Planner",
                    subtitle: "View your meals",
                    icon: "calendar",
                    action: onOpenMeals
                )
            }
        }
    }

    private func quickAction(
        title: String,
        subtitle: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            HStack(spacing: 10) {

                Image(systemName: icon)
                    .font(.system(size: 23))
                    .foregroundColor(purple)

                VStack(alignment: .leading, spacing: 4) {

                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(13)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
