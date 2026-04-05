import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: AddGoalViewModel
    var onSave: () -> Void

    @FocusState private var focusedField: Field?
    @State private var showDeleteConfirmation = false
    @State private var saveTrigger = false

    enum Field { case name, amount }

    private let iconColumns = [GridItem(.adaptive(minimum: 60), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                nameSection
                amountSection
                deadlineSection
                iconSection
                actionButtons
            }
            .padding(.vertical)
        }
        .background(Color.appBackground)
        .navigationTitle(viewModel.isEditing ? "Edit Goal" : "New Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
        .sensoryFeedback(.success, trigger: saveTrigger)
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Goal Name")
                .font(.headline)

            TextField("e.g., Vacation Fund", text: $viewModel.nameText)
                .font(.title3)
                .focused($focusedField, equals: .name)
                .padding(12)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }

    // MARK: - Amount

    private var amountSection: some View {
        VStack(spacing: 8) {
            Text("Target Amount")
                .font(.headline)

            TextField("0.00", text: $viewModel.amountText)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appPrimary)
                .focused($focusedField, equals: .amount)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Deadline

    private var deadlineSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target Date")
                .font(.headline)
                .padding(.horizontal)

            DatePicker("Deadline", selection: $viewModel.deadline, in: Date.now..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding(12)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
        }
    }

    // MARK: - Icon Picker

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: iconColumns, spacing: 12) {
                ForEach(AddGoalViewModel.availableIcons, id: \.self) { icon in
                    let isSelected = viewModel.selectedIcon == icon

                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.appPrimary : Color.appPrimary.opacity(0.1))
                            .frame(width: 48, height: 48)

                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundStyle(isSelected ? .white : Color.appPrimary)
                    }
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                    .onTapGesture {
                        viewModel.selectedIcon = icon
                    }
                }
            }
            .sensoryFeedback(.selection, trigger: viewModel.selectedIcon)
            .padding(.horizontal)
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.save(context: context)
                saveTrigger.toggle()
                onSave()
                dismiss()
            } label: {
                Text(viewModel.saveButtonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.isValid)

            if viewModel.isEditing {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete Goal")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .confirmationDialog(
                    "Delete this goal?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        viewModel.deleteGoal(context: context)
                        onSave()
                        dismiss()
                    }
                } message: {
                    Text("This will permanently remove the goal.")
                }
            }
        }
        .padding(.horizontal)
    }
}
