//
//  PersonalFinanceApp.swift
//  PersonalFinance
//
//  Created by Hari's Mac on 04.04.2026.
//

import SwiftUI
import SwiftData

@main
struct PersonalFinanceApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isBiometricEnabled") private var biometricEnabled = false
    @State private var isUnlocked = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else if biometricEnabled && !isUnlocked {
                    LockScreenView { isUnlocked = true }
                } else {
                    MainTabView()
                }
            }
            .onChange(of: biometricEnabled) {
                if !biometricEnabled { isUnlocked = true }
            }
        }
        .modelContainer(for: [Transaction.self, SavingsGoal.self, GoalContribution.self, NoSpendChallenge.self, Budget.self])
    }

    init() {
        // Configure the model container and seed data if empty
        let schema = Schema([Transaction.self, SavingsGoal.self, GoalContribution.self, NoSpendChallenge.self, Budget.self])
        let config = ModelConfiguration(schema: schema)
        if let container = try? ModelContainer(for: schema, configurations: config) {
            let context = ModelContext(container)
            MockDataService.populateIfEmpty(context: context)
            try? context.save()
        }
    }
}
