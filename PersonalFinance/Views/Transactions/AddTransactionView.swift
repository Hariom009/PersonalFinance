import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: AddTransactionViewModel
    var onSave: () -> Void

    @FocusState private var focusedField: Field?
    @State private var showDeleteConfirmation = false
    @State private var saveTrigger = false

    enum Field { case amount, note }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                amountSection
                typeToggle
                categorySection
                detailsSection
                actionButtons
            }
            .padding(.vertical)
        }
        .background(Color.appBackground)
        .navigationTitle(viewModel.isEditing ? "Edit Transaction" : "New Transaction")
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

    // MARK: - Amount Input

    private var amountSection: some View {
        VStack(spacing: 8) {
            TextField("0.00", text: $viewModel.amountText)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .foregroundStyle(viewModel.type == .income ? .incomeGreen : .expenseRed)
                .focused($focusedField, equals: .amount)

            Text(viewModel.type == .income ? "Income" : "Expense")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Type Toggle

    private var typeToggle: some View {
        Picker("Type", selection: $viewModel.type) {
            ForEach(TransactionType.allCases) { type in
                Text(type.title).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .onChange(of: viewModel.type) {
            viewModel.category = nil
        }
    }

    // MARK: - Category Picker

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
                .padding(.horizontal)

            CategoryGridView(
                categories: viewModel.availableCategories,
                selected: $viewModel.category
            )
            .padding(.horizontal)
        }
    }

    // MARK: - Details Card

    private var detailsSection: some View {
        VStack(spacing: 0) {
            DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                .padding(.horizontal)
                .padding(.vertical, 12)

            Divider().padding(.horizontal)

            HStack {
                Image(systemName: "note.text")
                    .foregroundStyle(.secondary)
                TextField("Add a note...", text: $viewModel.note)
                    .focused($focusedField, equals: .note)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            Divider().padding(.horizontal)

            Toggle(isOn: $viewModel.isRecurring) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(.secondary)
                    Text("Recurring")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    // MARK: - Action Buttons

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
                    Text("Delete Transaction")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .confirmationDialog(
                    "Delete this transaction?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        viewModel.deleteTransaction(context: context)
                        onSave()
                        dismiss()
                    }
                } message: {
                    Text("This action cannot be undone.")
                }
            }
        }
        .padding(.horizontal)
    }
}
