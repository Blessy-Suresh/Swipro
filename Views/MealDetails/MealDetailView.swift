
import SwiftUI

struct MealDetailView: View {

    @EnvironmentObject private var store: MealPlannerStore
    @Environment(\.dismiss) private var dismiss

    let meal: MealPlanItem

    private let purple = Color(
        red: 0.43,
        green: 0.32,
        blue: 0.60
    )

    private var currentMeal: MealPlanItem {
        store.meals.first(where: {
            $0.id == meal.id
        }) ?? meal
    }

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 20) {

                mealImage

                Text(currentMeal.dishName)
                    .font(.system(size: 25, weight: .bold))

                detailRow(
                    "Date",
                    value: currentMeal.date.formatted(
                        date: .complete,
                        time: .omitted
                    ),
                    icon: "calendar"
                )

                detailRow(
                    "Meal Type",
                    value: currentMeal.mealType,
                    icon: "fork.knife"
                )

                detailRow(
                    "Servings",
                    value: "\(currentMeal.servings)",
                    icon: "person.2"
                )

                VStack(alignment: .leading, spacing: 10) {

                    Text("Meal Status")
                        .font(.headline)

                    Picker(
                        "Status",
                        selection: Binding(
                            get: {
                                currentMeal.status
                            },
                            set: { newStatus in
                                store.updateStatus(
                                    for: meal.id,
                                    status: newStatus
                                )
                            }
                        )
                    ) {

                        ForEach(
                            MealPlanStatus.allCases,
                            id: \.self
                        ) { status in

                            Text(status.rawValue)
                                .tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(purple)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 13))

                VStack(alignment: .leading, spacing: 10) {

                    Text("Notes & Ingredients")
                        .font(.headline)

                    Text(
                        currentMeal.notes.isEmpty
                        ? "No notes added."
                        : currentMeal.notes
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 13))

                Button(role: .destructive) {

                    store.deleteMeal(meal)
                    dismiss()

                } label: {

                    Label(
                        "Delete Meal",
                        systemImage: "trash"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
        }
        .background(
            Color(
                red: 0.98,
                green: 0.97,
                blue: 0.99
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Meal Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var mealImage: some View {

        Group {

            if let _ = UIImage(named: currentMeal.imageName) {

                Image(currentMeal.imageName)
                    .resizable()
                    .scaledToFill()

            } else {

                Image(systemName: "fork.knife")
                    .font(.system(size: 45))
                    .foregroundColor(purple)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        Color(
                            red: 0.95,
                            green: 0.92,
                            blue: 0.98
                        )
                    )
            }
        }
        .frame(height: 210)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func detailRow(
        _ title: String,
        value: String,
        icon: String
    ) -> some View {

        HStack(spacing: 12) {

            Image(systemName: icon)
                .foregroundColor(purple)
                .frame(width: 25)

            Text(title)
                .font(.system(size: 14, weight: .medium))

            Spacer()

            Text(value)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(15)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
