import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: AddTransactionViewModel
    var onSave: () -> Void

    @FocusState private var focusedField: Field?
    @State private var showDeleteConfirmation = false
    @State private var showValidationAlert = false
    @State private var showValidationHints = false
    @State private var saveTrigger = false

    enum Field { case amount, note }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                amountSection
                typeToggle
                categorySection
                detailsSection
                if viewModel.isEditing {
                    deleteButton
                }
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
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    if viewModel.isValid {
                        viewModel.save(context: context)
                        saveTrigger.toggle()
                        onSave()
                        dismiss()
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showValidationHints = true
                        }
                        showValidationAlert = true
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(viewModel.isValid ? Color.black : .gray.opacity(0.4))
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.isValid)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
        .sensoryFeedback(.success, trigger: saveTrigger)
        .onChange(of: viewModel.isValid) {
            if viewModel.isValid && showValidationHints {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showValidationHints = false
                }
            }
        }
        .alert("Missing Info", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.validationMessage)
        }
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

            HStack(spacing: 2) {
                if showValidationHints && viewModel.amountValue <= 0 {
                    Image(systemName: "staroflife.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.red)
                        .transition(.scale.combined(with: .opacity))
                }
                Text(viewModel.type == .income ? "Income" : "Expense")
                    .font(.footnote)
                    .foregroundStyle(showValidationHints && viewModel.amountValue <= 0 ? .red : .secondary)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.25), value: viewModel.type)
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
            HStack(spacing: 4) {
                Text("Category")
                    .font(.system(.headline, design: .serif))
                if showValidationHints && viewModel.category == nil {
                    Image(systemName: "staroflife.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.red)
                        .transition(.scale.combined(with: .opacity))
                }
            }
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

    // MARK: - Delete Button

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Text("Delete Transaction")
                .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
        .padding(.horizontal)
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
