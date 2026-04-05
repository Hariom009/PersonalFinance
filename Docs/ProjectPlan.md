# Personal Finance Companion App - Project Plan

## Tech Stack
- **Framework:** SwiftUI (iOS 17+)
- **Data Persistence:** SwiftData (Apple's modern persistence framework)
- **Charts:** Swift Charts framework
- **Architecture:** MVVM with clear separation of UI / ViewModel / Model layers
- **State Management:** @Observable (Observation framework) + SwiftData @Query
- **Navigation:** NavigationStack with programmatic routing

---

## Data Models (Core)

```
Transaction
├── id: UUID
├── amount: Double
├── type: TransactionType (income | expense)
├── category: Category (food, transport, entertainment, bills, salary, freelance, etc.)
├── date: Date
├── note: String
├── isRecurring: Bool

SavingsGoal
├── id: UUID
├── name: String
├── targetAmount: Double
├── currentAmount: Double
├── deadline: Date
├── iconName: String

Budget
├── id: UUID
├── category: Category
├── monthlyLimit: Double
├── month: Date

UserProfile
├── currency: String
├── monthlyIncomeTarget: Double
├── createdAt: Date
```

---

## Phase 1 - Foundation & Data Layer (Day 1-2)

**Goal:** Project skeleton, models, persistence, and basic navigation shell.

### Tasks
1. **Project setup**
   - Create folder structure: `Models/`, `Views/`, `ViewModels/`, `Services/`, `Components/`, `Extensions/`, `Resources/`
   - Add SwiftData model container configuration in App entry point

2. **Data models**
   - `Transaction` model with SwiftData `@Model` macro
   - `SavingsGoal` model
   - `Category` enum with icon/color mappings
   - `TransactionType` enum

3. **Data service layer**
   - `TransactionService` - CRUD operations on transactions
   - `GoalService` - CRUD on savings goals
   - Seed data / mock data generator for development & empty-state prevention

4. **Navigation shell**
   - TabView with 4 tabs: Home, Transactions, Goals, Insights
   - Placeholder views for each tab
   - Custom tab bar styling

**Deliverable:** App launches, navigates between tabs, models persist via SwiftData.

---

## Phase 2 - Transaction Tracking (Day 2-3)

**Goal:** Full transaction CRUD with polished mobile UX.

### Tasks
1. **Add Transaction screen**
   - Amount input with numeric keypad feel (large prominent field)
   - Income/Expense segmented toggle
   - Category picker (grid of icons)
   - Date picker (defaults to today)
   - Optional notes text field
   - Save button with validation

2. **Transaction list screen**
   - Grouped by date (Today, Yesterday, This Week, Earlier)
   - Each row: category icon, title/note, amount (green for income, red for expense)
   - Swipe-to-delete
   - Tap to edit (reuse Add screen in edit mode)

3. **Search & filter**
   - Search bar at top of transaction list
   - Filter chips: All / Income / Expense
   - Category filter dropdown
   - Date range filter

4. **Empty state**
   - Friendly illustration + "No transactions yet" message with CTA to add first one

5. **Transaction ViewModel**
   - `TransactionListViewModel` - filtering, searching, grouping logic
   - `AddTransactionViewModel` - form validation, save/update logic

**Deliverable:** Users can add, view, edit, delete, search, and filter transactions.

---

## Phase 3 - Home Dashboard (Day 3-4)

**Goal:** Informative at-a-glance dashboard with charts.

### Tasks
1. **Summary cards**
   - Current balance card (income - expenses) - large, prominent
   - Income total card (this month)
   - Expense total card (this month)
   - Cards use SF Symbols and color coding

2. **Spending chart (Swift Charts)**
   - Weekly bar chart showing daily spending for current week
   - Each bar color-coded or interactive
   - Tappable to show day details

3. **Category breakdown**
   - Donut/ring chart showing expense distribution by category
   - Legend with category name + percentage + amount
   - Top 5 categories, rest grouped as "Other"

4. **Recent transactions**
   - Last 5 transactions as a compact list
   - "See All" link navigating to Transactions tab

5. **Quick action FAB**
   - Floating "+" button to quickly add a transaction from home

6. **Dashboard ViewModel**
   - `DashboardViewModel` - computes balance, totals, chart data, category breakdown
   - Reactive to transaction changes via SwiftData queries

**Deliverable:** Dashboard shows live financial summary with charts.

---

## Phase 4 - Savings Goals & Challenge Feature (Day 4-5)

**Goal:** Engaging goal tracking + a creative "No-Spend Challenge" feature.

### Tasks
1. **Savings Goals list**
   - Cards showing goal name, progress bar, amount saved vs target, deadline
   - Add new goal sheet
   - Tap to view goal detail

2. **Goal detail screen**
   - Large circular progress indicator (animated)
   - "Add funds" button (logs a contribution)
   - History of contributions
   - Edit / delete goal
   - Days remaining countdown

3. **No-Spend Challenge (Creative Feature)**
   - Users set a "no-spend streak" challenge (e.g., no unnecessary expenses for X days)
   - Calendar-style view showing streak days (green = no spend, red = broke streak)
   - Current streak counter with flame icon
   - Personal best streak display
   - Categories that "don't count" (bills, rent) are configurable
   - Motivational messages at milestones (3 days, 7 days, 14 days, 30 days)
   - Share streak (export as image)

4. **Smart Budget Alerts**
   - Users set monthly budget per category
   - Progress bar per category showing spent vs limit
   - Warning state at 80%, danger state at 100%
   - Subtle banner on dashboard when approaching a limit

**Deliverable:** Users can create goals, track progress, run no-spend challenges, and set category budgets.

---

## Phase 5 - Insights Screen (Day 5-6)

**Goal:** Data-driven insights that feel useful on mobile.

### Tasks
1. **Top spending category**
   - Card highlighting the biggest expense category this month
   - Comparison with last month (up/down arrow + percentage)

2. **Weekly comparison**
   - Side-by-side bar chart: this week vs last week
   - Summary: "You spent 12% less this week"

3. **Monthly trend**
   - Line chart showing monthly totals over last 6 months
   - Separate lines for income and expenses

4. **Spending by category**
   - Horizontal bar chart ranking categories by amount
   - Each bar tappable to see transactions in that category

5. **Quick stats**
   - Average daily spend
   - Most frequent transaction type
   - Biggest single expense this month
   - Days since last income

6. **Insights ViewModel**
   - `InsightsViewModel` - all computation, comparisons, trend calculations

**Deliverable:** Insights screen with multiple data visualizations and actionable info.

---

## Phase 6 - Polish & UX Excellence (Day 6-7)

**Goal:** Make it feel like a real product, not a prototype.

### Tasks
1. **Loading states**
   - Skeleton/shimmer placeholders on dashboard while computing
   - Smooth transitions when data loads

2. **Error states**
   - Graceful handling of data errors
   - Retry actions where applicable

3. **Empty states (all screens)**
   - Custom illustrations or SF Symbols + helpful copy
   - CTAs guiding user to take action

4. **Animations & transitions**
   - Smooth sheet presentations
   - Chart animations on appear
   - Progress bar animations
   - Haptic feedback on key actions (add transaction, complete goal)

5. **Dark mode**
   - Full dark mode support using adaptive colors
   - Test all screens in both modes

6. **Form UX refinements**
   - Keyboard handling (dismiss, next field)
   - Input validation with inline errors
   - Confirmation dialogs for destructive actions (delete)

7. **Accessibility**
   - VoiceOver labels on charts and custom components
   - Dynamic Type support

**Deliverable:** App feels polished, handles edge cases, supports dark mode.

---

## Phase 7 - Optional Enhancements & Documentation (Day 7-8)

**Goal:** Stretch features + comprehensive documentation.

### Tasks (pick based on time)
1. **Biometric lock** - FaceID/TouchID on app launch
2. **Data export** - Export transactions as CSV
3. **Notifications** - Daily reminder to log transactions
4. **Onboarding flow** - 3-screen walkthrough on first launch
5. **Profile/Settings screen** - Currency, name, reset data, app info
6. **Multi-currency** - Currency selector with symbol formatting
7. **Recurring transactions** - Auto-add monthly bills

8. **README.md**
   - Project overview and motivation
   - Screenshots (light + dark mode)
   - Architecture diagram
   - Setup instructions
   - Feature list with descriptions
   - Assumptions and design decisions
   - Known limitations and future improvements

9. **Code documentation**
   - Inline comments on non-obvious logic
   - Clean commit history with descriptive messages

**Deliverable:** Enhanced app + thorough documentation.

---

## Folder Structure

```
PersonalFinance/
├── App/
│   └── PersonalFinanceApp.swift
├── Models/
│   ├── Transaction.swift
│   ├── SavingsGoal.swift
│   ├── Budget.swift
│   ├── Category.swift
│   └── UserProfile.swift
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── TransactionListViewModel.swift
│   ├── AddTransactionViewModel.swift
│   ├── GoalsViewModel.swift
│   ├── InsightsViewModel.swift
│   └── ChallengeViewModel.swift
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── BalanceCardView.swift
│   │   ├── SpendingChartView.swift
│   │   └── CategoryBreakdownView.swift
│   ├── Transactions/
│   │   ├── TransactionListView.swift
│   │   ├── AddTransactionView.swift
│   │   └── TransactionRowView.swift
│   ├── Goals/
│   │   ├── GoalsListView.swift
│   │   ├── GoalDetailView.swift
│   │   ├── AddGoalView.swift
│   │   └── ChallengeView.swift
│   ├── Insights/
│   │   ├── InsightsView.swift
│   │   ├── WeeklyComparisonView.swift
│   │   └── MonthlyTrendView.swift
│   └── Common/
│       ├── MainTabView.swift
│       ├── EmptyStateView.swift
│       └── StatCardView.swift
├── Services/
│   ├── TransactionService.swift
│   ├── GoalService.swift
│   └── MockDataService.swift
├── Extensions/
│   ├── Date+Extensions.swift
│   ├── Double+Currency.swift
│   └── Color+Theme.swift
├── Resources/
│   └── Assets.xcassets
└── Docs/
    ├── ProjectPlan.md
    └── README.md
```

---

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Persistence | SwiftData | Native Apple framework, minimal boilerplate, works seamlessly with SwiftUI |
| Architecture | MVVM | Industry standard for SwiftUI, clean separation of concerns |
| Charts | Swift Charts | Native framework, no third-party dependency, great SwiftUI integration |
| Navigation | NavigationStack + TabView | Standard iOS patterns, familiar to users |
| State | @Observable | Modern, performant, less boilerplate than ObservableObject |
| Creative Feature | No-Spend Challenge + Budget Alerts | Gamification drives engagement, budget alerts are practical |

---

## Risk Mitigation

- **Scope creep:** Each phase has a clear deliverable. Optional enhancements are isolated in Phase 7.
- **Data complexity:** Start with SwiftData which handles relationships and persistence simply.
- **Chart performance:** Swift Charts handles moderate data well; aggregate at ViewModel level for large datasets.
- **Time pressure:** Phases 1-5 cover all core requirements. Phase 6-7 are polish. Can ship after Phase 5 if needed.
