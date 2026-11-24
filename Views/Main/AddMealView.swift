import SwiftUI

struct AddMealView: View {

    @EnvironmentObject private var store: MealPlannerStore

    @State private var dishName: String = ""
    @State private var selectedType: MealType = .breakfast
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var servings: Int = 1
    @State private var notes: String = ""

    @State private var lastSavedDishName = ""
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var showBanner = false

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

                VStack(alignment: .leading, spacing: 20) {

                    if showBanner {
                        successBanner
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

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

            .alert("Meal Saved Successfully! 🎉", isPresented: $showingSuccess) {
                Button("OK", role: .cancel) {
                    resetForm()
                }
            } message: {
                Text("\"\(lastSavedDishName)\" has been saved and added to your Meals and Meal List.")
            }

            .alert("Unable to Save", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a valid dish name and select valid servings.")
            }
        }
    }

    // MARK: - Success Banner

    private var successBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text("Meal Saved Successfully!")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                Text("Added to Meals planner and Meal List.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                withAnimation {
                    showBanner = false
                }
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.06), radius: 5, y: 2)
    }

    // MARK: - Header

    private var header: some View {

        VStack(alignment: .leading, spacing: 7) {

            Text("Plan Your Meal")
                .font(.system(size: 22, weight: .bold))

            Text("Enter meal details below and tap Save Meal.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Dish Name

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

    // MARK: - Meal Type

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

    // MARK: - Date Selection (Compact, Web-style)

    private var dateSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Choose Date", icon: "calendar")

            HStack {
                Text("Meal Date")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                DatePicker(
                    "Meal Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(purple)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))

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

    // MARK: - Servings

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

    // MARK: - Notes

    private var notesSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Notes & Ingredients", icon: "note.text")

            TextEditor(text: $notes)
                .frame(height: 90)
                .padding(8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Save Button

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

    // MARK: - Section Title

    private func sectionTitle(
        _ title: String,
        icon: String
    ) -> some View {

        Label(title, systemImage: icon)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(purple)
    }

    // MARK: - Save Logic

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
            lastSavedDishName = cleanName
            showingSuccess = true
            withAnimation {
                showBanner = true
            }
        } else {
            showingError = true
        }
    }

    // MARK: - Reset Form

    private func resetForm() {
        dishName = ""
        selectedType = .breakfast
        selectedDate = Calendar.current.startOfDay(for: Date())
        servings = 1
        notes = ""
    }
}
