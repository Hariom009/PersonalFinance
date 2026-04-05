import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = SettingsViewModel()
    @AppStorage("userName") private var userName = ""
    @AppStorage("isBiometricEnabled") private var biometricEnabled = false

    var body: some View {
        List {
            profileSection
            preferencesSection
            securitySection
            dataSection
            aboutSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.exportTransactions(context: context) }
    }

    // MARK: - Profile

    private var profileSection: some View {
        Section {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appPrimary)
                }

                TextField("Your Name", text: $userName)
                    .font(.body)
            }
        } header: {
            Text("Profile")
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        Section {
            HStack {
                Label("Currency", systemImage: "dollarsign.circle")
                Spacer()
                Text("\(viewModel.currencySymbol) (\(viewModel.currencyCode))")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Preferences")
        }
    }

    // MARK: - Security

    private var securitySection: some View {
        Section {
            Toggle(isOn: $biometricEnabled) {
                Label("Lock with \(BiometricService.biometricType)", systemImage: "lock.shield")
            }
            .disabled(!BiometricService.isBiometricAvailable)

            if !BiometricService.isBiometricAvailable {
                Text("Biometric authentication is not available on this device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Security")
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        Section {
            if let url = viewModel.exportURL {
                ShareLink(item: url) {
                    Label("Export Transactions (CSV)", systemImage: "square.and.arrow.up")
                }
            } else {
                Button {
                    viewModel.exportTransactions(context: context)
                } label: {
                    Label("Prepare Export", systemImage: "square.and.arrow.up")
                }
            }

            Button(role: .destructive) {
                viewModel.showResetConfirmation = true
            } label: {
                Label("Reset All Data", systemImage: "trash")
                    .foregroundStyle(.expenseRed)
            }
            .confirmationDialog(
                "Reset all data?",
                isPresented: $viewModel.showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset Everything", role: .destructive) {
                    viewModel.resetAllData(context: context)
                }
            } message: {
                Text("This will permanently delete all transactions, goals, budgets, and challenges. Data will be re-seeded on next launch.")
            }
        } header: {
            Text("Data")
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Developer")
                Spacer()
                Text("Hariom")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}
