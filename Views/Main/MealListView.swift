import SwiftUI
import UIKit

struct MealListView: View {

    @EnvironmentObject private var store: MealPlannerStore

    @State private var searchText = ""
    @State private var selectedMeal: MealPlanItem?
    @State private var mealToEdit: MealPlanItem?

    private let purple = Color(
        red: 0.43, green: 0.32, blue: 0.60
    )

    private let lavender = Color(
        red: 0.95, green: 0.92, blue: 0.98
    )

    private var filteredMeals: [MealPlanItem] {

        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if query.isEmpty {
            return store.meals.sorted {
                $0.date < $1.date
            }
        }

        return store.meals.filter {
            $0.dishName.localizedCaseInsensitiveContains(query) ||
            $0.mealType.localizedCaseInsensitiveContains(query) ||
            $0.status.rawValue.localizedCaseInsensitiveContains(query)
        }
        .sorted {
            $0.date < $1.date
        }
    }

    private var groupedDates: [Date] {

        let calendar = Calendar.current

        return Array(
            Set(filteredMeals.map {
                calendar.startOfDay(for: $0.date)
            })
        )
        .sorted()
    }

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 18) {

                    searchBar

                    HStack {
                        Text("Your Meal Plan")
                            .font(.system(size: 21, weight: .bold))

                        Spacer()

                        Text("\(filteredMeals.count) meals")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(purple)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(lavender)
                            .clipShape(Capsule())
                    }

                    if filteredMeals.isEmpty {

                        emptyState

                    } else {

                        ForEach(groupedDates, id: \.self) { date in

                            VStack(alignment: .leading, spacing: 12) {

                                Text(date.formatted(
                                    .dateTime.weekday(.wide).day().month(.wide)
                                ))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(purple)

                                ForEach(
                                    filteredMeals.filter {
                                        Calendar.current.isDate(
                                            $0.date,
                                            inSameDayAs: date
                                        )
                                    }
                                ) { meal in

                                    mealRow(meal)
                                }
                            }
                        }
                    }
                }
                .padding(18)
            }
            .background(
                Color(red: 0.98, green: 0.97, blue: 0.99)
                    .ignoresSafeArea()
            )
            .navigationTitle("Meal List")
            .sheet(item: $selectedMeal) { meal in
                NavigationStack {
                    MealDetailView(meal: meal)
                }
            }
            .sheet(item: $mealToEdit) { meal in
                EditMealView(meal: meal)
            }
        }
    }

    // MARK: Search

    private var searchBar: some View {

        HStack(spacing: 10) {

            Image(systemName: "magnifyingglass")
                .foregroundColor(purple)

            TextField("Search dish or meal type", text: $searchText)
                .font(.system(size: 14))
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Meal Row

    private func mealRow(_ meal: MealPlanItem) -> some View {

        Button {
            selectedMeal = meal
        } label: {

            HStack(spacing: 12) {

                Group {
                    if UIImage(named: meal.imageName) != nil {
                        Image(meal.imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 23))
                            .foregroundColor(purple)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(lavender)
                    }
                }
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 6) {

                    Text(meal.dishName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(meal.mealType)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

                    Text("\(meal.servings) servings")
                        .font(.system(size: 11))
                        .foregroundColor(purple)

                    Text(meal.status.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(purple)
                }

                Spacer()

                // Direct edit button
                Button {
                    mealToEdit = meal
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(purple)
                }
                .buttonStyle(.borderless)

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 13))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                mealToEdit = meal
            } label: {
                Label("Edit Meal", systemImage: "pencil")
            }

            Button(role: .destructive) {
                store.deleteMeal(meal)
            } label: {
                Label("Delete Meal", systemImage: "trash")
            }
        }
    }

    // MARK: Empty State

    private var emptyState: some View {

        VStack(spacing: 12) {

            Image(systemName: "list.clipboard")
                .font(.system(size: 42))
                .foregroundColor(purple)

            Text("No meals found")
                .font(.system(size: 16, weight: .semibold))

            Text("Add a meal to see it in your weekly list.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(35)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
