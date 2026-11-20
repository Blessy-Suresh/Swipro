
import SwiftUI

struct MealsView: View {

    @EnvironmentObject private var store: MealPlannerStore

    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var selectedPeriod = "Week"
    @State private var selectedMeal: MealPlanItem?

    private let purple = Color(
        red: 0.43, green: 0.32, blue: 0.60
    )

    private let lavender = Color(
        red: 0.95, green: 0.92, blue: 0.98
    )

    private var dates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7

        let monday = calendar.date(
            byAdding: .day,
            value: -daysFromMonday,
            to: today
        ) ?? today

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: monday)
        }
    }

    private var displayedMeals: [MealPlanItem] {
        switch selectedPeriod {
        case "Today":
            return store.meals(for: selectedDate)
        case "Month":
            return store.meals.filter {
                Calendar.current.isDate(
                    $0.date,
                    equalTo: selectedDate,
                    toGranularity: .month
                )
            }.sorted { $0.date < $1.date }
        default:
            return store.meals(forWeekContaining: selectedDate)
        }
    }

    var body: some View {

        NavigationStack {

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 22) {

                    periodSelector

                    dateSelector

                    HStack {
                        Text(selectedPeriod == "Today"
                             ? "Daily Meals"
                             : selectedPeriod == "Month"
                             ? "Monthly Meals"
                             : "Weekly Meal Plan")
                            .font(.system(size: 19, weight: .bold))

                        Spacer()

                        Text("\(displayedMeals.count) meals")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(purple)
                    }

                    if displayedMeals.isEmpty {

                        emptyState

                    } else {

                        ForEach(displayedMeals, id: \.id) { meal in
                            mealCard(meal)
                        }
                    }
                }
                .padding(18)
                .padding(.bottom, 25)
            }
            .background(
                Color(red: 0.98, green: 0.97, blue: 0.99)
                    .ignoresSafeArea()
            )
            .navigationTitle("Meal Planner")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedMeal) { meal in
                NavigationStack {
                    MealDetailView(meal: meal)
                }
            }
        }
    }

    // MARK: Period Selector

    private var periodSelector: some View {

        HStack(spacing: 5) {

            ForEach(["Today", "Week", "Month"], id: \.self) { period in

                Button {
                    selectedPeriod = period
                } label: {

                    Text(period)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(
                            selectedPeriod == period ? .white : purple
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedPeriod == period ? purple : .clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(5)
        .background(lavender)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Date Selector

    private var dateSelector: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text(selectedDate.formatted(
                .dateTime.month(.wide).year()
            ))
            .font(.system(size: 17, weight: .bold))

            if selectedPeriod == "Week" || selectedPeriod == "Today" {

                HStack(spacing: 7) {

                    ForEach(dates, id: \.self) { date in

                        Button {
                            selectedDate = date
                        } label: {

                            VStack(spacing: 7) {

                                Text(date.formatted(
                                    .dateTime.weekday(.narrow)
                                ))

                                Text(date.formatted(
                                    .dateTime.day()
                                ))
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(
                                Calendar.current.isDate(
                                    date,
                                    inSameDayAs: selectedDate
                                ) ? .white : purple
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Calendar.current.isDate(
                                    date,
                                    inSameDayAs: selectedDate
                                ) ? purple : lavender
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }

            } else {

                DatePicker(
                    "Choose month",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .tint(purple)
            }
        }
    }

    // MARK: Meal Card

    private func mealCard(_ meal: MealPlanItem) -> some View {

        Button {
            selectedMeal = meal
        } label: {

            HStack(spacing: 12) {

                mealImage(meal.imageName)

                VStack(alignment: .leading, spacing: 6) {

                    Text(meal.dishName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    Text("\(meal.mealType) · \(meal.servings) servings")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Text(meal.date.formatted(
                        .dateTime.weekday(.abbreviated).day().month(.abbreviated)
                    ))
                    .font(.system(size: 11))
                    .foregroundColor(purple)

                    statusBadge(meal.status)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func mealImage(_ name: String) -> some View {

        Group {
            if UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "fork.knife")
                    .font(.system(size: 25))
                    .foregroundColor(purple)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(lavender)
            }
        }
        .frame(width: 76, height: 76)
        .clipShape(RoundedRectangle(cornerRadius: 11))
    }

    private func statusBadge(_ status: MealPlanStatus) -> some View {

        Text(status.rawValue)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(purple)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(lavender)
            .clipShape(Capsule())
    }

    // MARK: Empty State

    private var emptyState: some View {

        VStack(spacing: 12) {

            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(purple)

            Text("No meals planned yet")
                .font(.system(size: 16, weight: .semibold))

            Text("Your saved meals will appear here, organized by date.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(35)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
