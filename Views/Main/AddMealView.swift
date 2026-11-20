
import SwiftUI

struct AddMealView: View {

    @EnvironmentObject private var store: MealPlannerStore

    @State private var dishName = ""
    @State private var selectedType: MealType = .breakfast
    @State private var selectedDate = Calendar.current.startOfDay(
        for: Date()
    )
    @State private var servings = 1
    @State private var notes = ""

    @State private var showingSuccess = false
    @State private var showingError = false

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

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 22) {

                    header

                    dishNameSection

                    mealTypeSection

                    dateSection

                    servingsSection

                    notesSection

                    saveButton
                }
                .padding(20)
                .padding(.bottom, 25)
            }
            .background(
                Color(
                    red: 0.98,
                    green: 0.97,
                    blue: 0.99
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.large)

            .alert("Meal Saved!", isPresented: $showingSuccess) {
                Button("OK", role: .cancel) {
                    resetForm()
                }
            } message: {
                Text("Your meal has been added to your meal plan.")
            }

            .alert("Unable to Save", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Enter a valid dish name and servings, and select a valid date.")
            }
        }
    }

    // MARK: Header

    private var header: some View {

        VStack(alignment: .leading, spacing: 7) {

            Text("Plan Your Meal")
                .font(.system(size: 22, weight: .bold))

            Text("Add your meals to your weekly planner.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }

    // MARK: Dish Name

    private var dishNameSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Dish Name", icon: "fork.knife")

            TextField(
                "Enter dish name",
                text: $dishName
            )
            .padding(15)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: Meal Type

    private var mealTypeSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Meal Type", icon: "clock")

            Picker("Meal Type", selection: $selectedType) {

                ForEach(MealType.allCases) { type in

                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)
            .tint(purple)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: Date Selection

    private var dateSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Choose Date", icon: "calendar")

            DatePicker(
                "Meal Date",
                selection: $selectedDate,
                in: Calendar.current.startOfDay(for: Date())...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(purple)
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(
                "Selected: " +
                selectedDate.formatted(
                    date: .complete,
                    time: .omitted
                )
            )
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(purple)
        }
    }

    // MARK: Servings

    private var servingsSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Number of Servings", icon: "person.2")

            Stepper(
                "\(servings) Servings",
                value: $servings,
                in: 1...20
            )
            .padding(15)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: Notes

    private var notesSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Notes & Ingredients", icon: "note.text")

            TextEditor(text: $notes)
                .frame(height: 110)
                .padding(8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: Save Button

    private var saveButton: some View {

        Button {

            saveMeal()

        } label: {

            HStack {

                Image(systemName: "checkmark.circle.fill")

                Text("Save Meal")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(purple)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: Section Title

    private func sectionTitle(
        _ title: String,
        icon: String
    ) -> some View {

        Label(title, systemImage: icon)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(purple)
    }

    // MARK: Save Logic

    private func saveMeal() {

        let cleanName = dishName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanName.isEmpty else {
            showingError = true
            return
        }

        let meal = MealPlanItem(
            dishName: cleanName,
            date: selectedDate,
            mealType: selectedType.rawValue,
            servings: servings,
            notes: notes,
            status: .planned,
            imageName: "MealDefault"
        )

        if store.addMeal(meal) {
            showingSuccess = true
        } else {
            showingError = true
        }
    }

    // MARK: Reset Form

    private func resetForm() {

        dishName = ""
        selectedType = .breakfast
        selectedDate = Calendar.current.startOfDay(
            for: Date()
        )
        servings = 1
        notes = ""
    }
}
