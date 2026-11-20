
import Foundation
import Combine

@MainActor
final class MealPlannerStore: ObservableObject {

    // MARK: - Shared Meal Data

    @Published private(set) var meals: [MealPlanItem] = []

    private let storageKey = "MealMateSavedMeals"

    // MARK: - Initialization

    init() {
        loadMeals()
    }

    // MARK: - Add Meal

    @discardableResult
    func addMeal(_ meal: MealPlanItem) -> Bool {

        let today = Calendar.current.startOfDay(
            for: Date()
        )

        let selectedDate = Calendar.current.startOfDay(
            for: meal.date
        )

        let cleanName = meal.dishName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard selectedDate >= today else {
            return false
        }

        guard !cleanName.isEmpty else {
            return false
        }

        guard meal.servings > 0 else {
            return false
        }

        var newMeal = meal
        newMeal.dishName = cleanName
        newMeal.date = selectedDate

        meals.append(newMeal)

        saveMeals()

        return true
    }

    // MARK: - Edit Meal

    @discardableResult
    func updateMeal(_ meal: MealPlanItem) -> Bool {

        guard let index = meals.firstIndex(
            where: { $0.id == meal.id }
        ) else {
            return false
        }

        let cleanName = meal.dishName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanName.isEmpty else {
            return false
        }

        guard meal.servings > 0 else {
            return false
        }

        let today = Calendar.current.startOfDay(
            for: Date()
        )

        let selectedDate = Calendar.current.startOfDay(
            for: meal.date
        )

        guard selectedDate >= today else {
            return false
        }

        var updatedMeal = meal
        updatedMeal.dishName = cleanName
        updatedMeal.date = selectedDate

        meals[index] = updatedMeal

        saveMeals()

        return true
    }

    // MARK: - Update Meal Status

    func updateStatus(
        for mealID: UUID,
        status: MealPlanStatus
    ) {

        guard let index = meals.firstIndex(
            where: { $0.id == mealID }
        ) else {
            return
        }

        meals[index].status = status

        saveMeals()
    }

    // MARK: - Delete Meal

    func deleteMeal(_ meal: MealPlanItem) {

        meals.removeAll {
            $0.id == meal.id
        }

        saveMeals()
    }

    // MARK: - Meals For Selected Date

    func meals(for date: Date) -> [MealPlanItem] {

        return meals
            .filter {
                Calendar.current.isDate(
                    $0.date,
                    inSameDayAs: date
                )
            }
            .sorted {
                mealOrder($0.mealType) <
                mealOrder($1.mealType)
            }
    }

    // MARK: - Weekly Meals

    func meals(forWeekContaining date: Date) -> [MealPlanItem] {

        var calendar = Calendar.current
        calendar.firstWeekday = 2

        guard let interval = calendar.dateInterval(
            of: .weekOfYear,
            for: date
        ) else {
            return []
        }

        return meals
            .filter {
                $0.date >= interval.start &&
                $0.date < interval.end
            }
            .sorted {

                if $0.date == $1.date {
                    return mealOrder($0.mealType) <
                           mealOrder($1.mealType)
                }

                return $0.date < $1.date
            }
    }

    // MARK: - Meal Ordering

    private func mealOrder(_ type: String) -> Int {

        switch type {

        case "Breakfast":
            return 0

        case "Lunch":
            return 1

        case "Snacks":
            return 2

        case "Dinner":
            return 3

        default:
            return 4
        }
    }

    // MARK: - Dashboard Statistics

    var plannedCount: Int {
        meals.filter {
            $0.status == .planned
        }.count
    }

    var cookedCount: Int {
        meals.filter {
            $0.status == .cooked
        }.count
    }

    var skippedCount: Int {
        meals.filter {
            $0.status == .skipped
        }.count
    }

    // MARK: - Save Meals

    private func saveMeals() {

        do {

            let encoder = JSONEncoder()

            let data = try encoder.encode(meals)

            UserDefaults.standard.set(
                data,
                forKey: storageKey
            )

        } catch {

            print(
                "Meal saving failed: \(error.localizedDescription)"
            )
        }
    }

    // MARK: - Load Meals

    private func loadMeals() {

        guard let data = UserDefaults.standard.data(
            forKey: storageKey
        ) else {

            meals = []
            return
        }

        do {

            let decoder = JSONDecoder()

            let savedMeals = try decoder.decode(
                [MealPlanItem].self,
                from: data
            )

            meals = savedMeals

        } catch {

            print(
                "Meal loading failed: \(error.localizedDescription)"
            )

            meals = []
        }
    }
}
