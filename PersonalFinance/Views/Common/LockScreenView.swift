import SwiftUI

struct LockScreenView: View {
    var onUnlock: () -> Void

    @State private var authFailed = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.appPrimary)

            Text("Personal Finance")
                .font(.title2.bold())

            Text("Your financial data is protected")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if authFailed {
                Text("Authentication failed. Try again.")
                    .font(.footnote)
                    .foregroundStyle(.expenseRed)
            }

            Button {
                Task { await authenticate() }
            } label: {
                Label("Unlock with \(BiometricService.biometricType)", systemImage: biometricIcon)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 40)

            Spacer()
        }
        .background(Color.appBackground)
        .task { await authenticate() }
    }

    private func authenticate() async {
        let success = await BiometricService.authenticate()
        await MainActor.run {
            if success {
                authFailed = false
                onUnlock()
            } else {
                authFailed = true
            }
        }
    }

    private var biometricIcon: String {
        let type = BiometricService.biometricType
        if type == "Face ID" { return "faceid" }
        if type == "Touch ID" { return "touchid" }
        if type == "Optic ID" { return "opticid" }
        return "lock.open"
    }
}
