# Personal Finance Companion

A lightweight, mobile-first personal finance tracker built with SwiftUI. Track transactions, set savings goals, take on no-spend challenges, and gain insights into your spending habits — all in a clean, intuitive interface.

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| **SwiftUI** | Declarative UI framework |
| **SwiftData** | Persistence (replaces Core Data) |
| **Swift Charts** | Bar, line, donut, and sector charts |
| **LocalAuthentication** | FaceID / TouchID biometric lock |
| **@Observable** | Modern state management (Observation framework) |
| **MVVM** | Architecture pattern |
| **iOS 26.1** | Deployment target |

## Features

### Home Dashboard
- Time-of-day greeting with monthly balance
- Income, expenses, and savings summary cards
- Weekly spending bar chart with today highlighted
- Category breakdown donut chart with legend
- Savings goals horizontal scroll
- Recent transactions with "See All" tab switching

### Transaction Tracking
- Add, edit, and delete transactions
- Income/expense type toggle with category grid picker
- Search and filter by type, category, and text
- Grouped by date (Today, Yesterday, This Week, Earlier)
- Swipe actions for edit and delete with confirmation dialogs
- Floating action button for quick entry

### Savings Goals
- Create goals with name, target amount, deadline, and icon
- Circular progress ring with animated fill
- Add funds with contribution history tracking
- Edit and delete with confirmation
- Active vs completed goal sections

### No-Spend Challenge
- Set target days for a no-spend streak
- Calendar grid visualization (green = no spend, red = broke streak)
- Current streak counter with flame icon
- Personal best tracking
- Configurable exempt categories (bills don't break your streak)
- Motivational messages at milestones (7, 14, 30 days)

### Budget Tracking
- Set monthly spending limits per category
- Color-coded progress bars (blue → orange at 80% → red at 100%)
- Over-budget warnings
- Context menu delete with confirmation

### Insights
- Top spending category with month-over-month comparison
- Weekly comparison chart (this week vs last week)
- 6-month income/expense trend line chart
- Category ranking horizontal bar chart
- Quick stats: average daily spend, most frequent category, biggest expense, days since income

### Settings & Extras
- Biometric lock (FaceID / TouchID)
- CSV data export via share sheet
- User profile name
- Reset all data with confirmation
- 3-page onboarding flow on first launch

## Architecture

```
Views (SwiftUI)
  ↓ @State, @Binding
ViewModels (@Observable)
  ↓ method calls
Services (struct)
  ↓ ModelContext
SwiftData Models (@Model)
```

**Key decisions:**
- **@Observable over ObservableObject** — less boilerplate, better performance, modern Swift
- **SwiftData over Core Data** — native Swift, automatic schema migration, cleaner API
- **Struct services with ModelContext parameter** — stateless, testable, no singleton overhead
- **String raw values on enums** — SwiftData-compatible, human-readable, forward-compatible
- **In-memory filtering over complex predicates** — responsive UI, simple code, adequate for local data size

## Project Structure

```
PersonalFinance/
├── Models/
│   ├── Transaction.swift          # Core transaction model
│   ├── TransactionType.swift      # Income / expense enum
│   ├── Category.swift             # 12 categories with icons & colors
│   ├── SavingsGoal.swift          # Goal with progress tracking
│   ├── GoalContribution.swift     # Individual fund additions
│   ├── NoSpendChallenge.swift     # Streak challenge model
│   └── Budget.swift               # Monthly category budget
├── ViewModels/
│   ├── DashboardViewModel.swift   # Dashboard data & charts
│   ├── TransactionListViewModel.swift
│   ├── AddTransactionViewModel.swift
│   ├── GoalsListViewModel.swift
│   ├── GoalDetailViewModel.swift
│   ├── AddGoalViewModel.swift
│   ├── ChallengeViewModel.swift   # Streak computation
│   ├── BudgetViewModel.swift
│   ├── InsightsViewModel.swift    # Analytics & trends
│   └── SettingsViewModel.swift
├── Views/
│   ├── Common/
│   │   ├── MainTabView.swift      # 4-tab navigation
│   │   ├── EmptyStateView.swift   # Reusable empty state
│   │   └── LockScreenView.swift   # Biometric lock screen
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── Transactions/
│   │   ├── TransactionListView.swift
│   │   └── AddTransactionView.swift
│   ├── Goals/
│   │   ├── GoalsListView.swift    # Segmented: Goals/Challenge/Budgets
│   │   ├── GoalDetailView.swift
│   │   ├── AddGoalView.swift
│   │   ├── ChallengeView.swift
│   │   └── BudgetListView.swift
│   ├── Insights/
│   │   └── InsightsView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Onboarding/
│       └── OnboardingView.swift
├── Services/
│   ├── TransactionService.swift   # Transaction CRUD + filtering
│   ├── GoalService.swift
│   ├── ContributionService.swift  # Atomic add/remove funds
│   ├── ChallengeService.swift     # Streak computation + calendar
│   ├── BudgetService.swift
│   ├── MockDataService.swift      # Seeds realistic sample data
│   ├── BiometricService.swift     # FaceID / TouchID wrapper
│   └── ExportService.swift        # CSV generation
├── Components/
│   ├── FilterChipView.swift       # Pill-shaped toggle buttons
│   ├── CategoryGridView.swift     # Category icon grid picker
│   ├── TransactionRowView.swift   # Transaction list row
│   ├── StatCardView.swift         # Summary stat card
│   ├── SectionHeaderView.swift    # Section title + action
│   ├── GoalCardView.swift         # Compact goal card
│   ├── CircularProgressView.swift # Animated progress ring
│   ├── StreakCalendarView.swift   # Day-by-day streak calendar
│   └── BudgetProgressRow.swift    # Budget progress bar
├── Extensions/
│   ├── Date+Extensions.swift      # Date helpers & formatting
│   ├── Double+Currency.swift      # Currency formatting
│   └── Color+Theme.swift          # App color palette
└── PersonalFinanceApp.swift       # Entry point + SwiftData config
```

## Setup Instructions

1. Clone the repository
2. Open `PersonalFinance.xcodeproj` in Xcode
3. Select an iOS 26.1 simulator (iPhone 16 recommended)
4. Build and run (Cmd + R)

The app seeds realistic sample data on first launch — 30+ transactions, 4 savings goals, an active no-spend challenge, and 4 category budgets.

## UX Polish

- **Delete confirmations** on all destructive actions
- **Keyboard "Done" toolbar** on all numeric/text inputs
- **Haptic feedback** on saves, deletes, tab switches, and filter selections
- **Loading states** with ProgressView on data-heavy screens
- **Empty states** with fade-in animation and actionable CTAs
- **Accessibility labels** on charts, progress bars, and custom components
- **Dark mode** supported via adaptive system colors

## Assumptions & Limitations

- Single-user, local-only app (no CloudKit or backend sync)
- Currency follows device locale (no manual multi-currency switching)
- Mock data auto-seeds on first launch for immediate demo
- Monthly trends show up to 6 months (limited by transaction history)
- No-spend challenge streak resets if non-exempt expenses are logged
- Biometric availability depends on device hardware and enrollment
