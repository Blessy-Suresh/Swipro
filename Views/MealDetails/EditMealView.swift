import SwiftUI

struct EditMealView: View {

    @EnvironmentObject private var store: MealPlannerStore
    @Environment(\.dismiss) private var dismiss

    let meal: MealPlanItem

    @State private var dishName: String
    @State private var selectedType: MealType
    @State private var selectedDate: Date
    @State private var servings: Int
    @State private var status: MealPlanStatus
    @State private var notes: String

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

    init(meal: MealPlanItem) {
        self.meal = meal
        _dishName = State(initialValue: meal.dishName)
        _selectedType = State(initialValue: MealType(rawValue: meal.mealType) ?? .lunch)
        _selectedDate = State(initialValue: meal.date)
        _servings = State(initialValue: meal.servings)
        _status = State(initialValue: meal.status)
        _notes = State(initialValue: meal.notes)
    }

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 20) {

                    dishNameSection

                    mealTypeSection

                    statusSection

                    dateSection

                    servingsSection

                    notesSection

                    saveButton
                }
                .padding(20)
                .padding(.bottom, 25)
            }
            .background(
                Color(red: 0.98, green: 0.97, blue: 0.99)
                    .ignoresSafeArea()
            )
            .navigationTitle("Edit Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(purple)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(purple)
                }
            }
            .alert("Meal Updated! 🎉", isPresented: $showingSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Your changes have been saved successfully.")
            }
            .alert("Unable to Save", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a valid dish name and select valid servings.")
            }
        }
    }

    // MARK: - Dish Name

    private var dishNameSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Dish Name", icon: "fork.knife")

            TextField("Enter dish name", text: $dishName)
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

    // MARK: - Status

    private var statusSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Meal Status", icon: "checkmark.circle")

            Picker("Status", selection: $status) {

                ForEach(MealPlanStatus.allCases, id: \.self) { s in

                    Text(s.rawValue)
                        .tag(s)
                }
            }
            .pickerStyle(.segmented)
            .padding(4)
            .background(lavender)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Date Section

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

            Text("Selected: " + selectedDate.formatted(date: .complete, time: .omitted))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(purple)
        }
    }

    // MARK: - Servings

    private var servingsSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            sectionTitle("Number of Servings", icon: "person.2")

            Stepper("\(servings) Servings", value: $servings, in: 1...20)
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
            saveChanges()
        } label: {

            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Changes")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(purple)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func sectionTitle(_ title: String, icon: String) -> some View {

        Label(title, systemImage: icon)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(purple)
    }

    // MARK: - Save Logic

    private func saveChanges() {

        let cleanName = dishName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanName.isEmpty else {
            showingError = true
            return
        }

        var updated = meal
        updated.dishName = cleanName
        updated.mealType = selectedType.rawValue
        updated.date = selectedDate
        updated.servings = servings
        updated.status = status
        updated.notes = notes

        if store.updateMeal(updated) {
            showingSuccess = true
        } else {
            showingError = true
        }
    }
}
