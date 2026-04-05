# Personal Finance Companion

A lightweight, mobile-first personal finance tracker built with **SwiftUI** and **SwiftData**. Track transactions, set savings goals, take on no-spend challenges, set category budgets, and explore spending insights — all in a clean, native iOS interface.

> Built as a single-user, offline-first iOS app. No account, no cloud, no tracking — your data lives on your device.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Tech Stack](#tech-stack)
3. [Requirements](#requirements)
4. [Setup Instructions](#setup-instructions)
5. [Features](#features)
6. [Architecture](#architecture)
7. [Project Structure](#project-structure)
8. [Data Model](#data-model)
9. [UX Polish](#ux-polish)
10. [Assumptions & Limitations](#assumptions--limitations)
11. [Roadmap / Possible Extensions](#roadmap--possible-extensions)

---

## Project Overview

**Personal Finance Companion** helps users build better money habits without the noise of a full-blown banking app. It combines four pillars of personal finance into one coherent experience:

| Pillar | What it does |
|---|---|
| **Track** | Log income and expenses with categories, notes, and dates |
| **Save** | Create goals, contribute funds, watch progress rings fill |
| **Budget** | Set monthly per-category limits with visual warnings |
| **Discipline** | Run no-spend challenges with streak calendars & milestones |

On top of that, an **Insights** tab surfaces trends — top spending categories, week-over-week changes, 6-month income/expense curves, and quick stats like average daily spend.

The app is designed to feel **instant**: data lives locally (SwiftData), all filtering happens in memory, and every destructive action has a confirmation. On first launch, it seeds realistic mock data so the app is fully usable immediately for demo or exploration.

---

## Tech Stack

| Technology | Purpose |
|---|---|
| **SwiftUI** | Declarative UI framework (all screens, animations, charts) |
| **SwiftData** | Persistence layer (replaces Core Data) with `@Model` macros |
| **Swift Charts** | Bar, line, donut, and sector charts in Dashboard & Insights |
| **Observation (`@Observable`)** | Modern state management (replaces `ObservableObject`) |
| **LocalAuthentication** | FaceID / TouchID biometric lock |
| **MVVM** | Architecture pattern (Views → ViewModels → Services → Models) |

**Target:** iOS 26.1 · iPhone (portrait-first) · Dark Mode supported.

---

## Requirements

- **macOS** 15 or newer (Sequoia+)
- **Xcode** 26 or newer
- **iOS Simulator** running iOS 26.1 (iPhone 16 recommended)
- A physical device is **only** required if you want to test FaceID / TouchID

No package managers, no external dependencies, no API keys. The project is pure first-party Apple frameworks.

---

## Setup Instructions

```bash
git clone <repo-url>
cd PersonalFinance
open PersonalFinance.xcodeproj
```

Then in Xcode:

1. Select an **iOS 26.1 simulator** (iPhone 16 Pro recommended) from the scheme bar.
2. Press **Cmd + R** to build and run.
3. On first launch, walk through the 3-page onboarding, then explore the seeded mock data.

**To reset the app to a fresh state:**
- In-app: Settings → **Reset All Data**
- Or: long-press the app icon in the simulator → **Delete App**, then rebuild.

**To test biometric lock:**
- Settings → toggle **Biometric Lock** on.
- In the simulator: **Features → Face ID → Enrolled**, then re-launch the app and use **Features → Face ID → Matching Face** when prompted.

---

## Features

### Home Dashboard
- Time-of-day greeting (Good morning / afternoon / evening) with user name
- Monthly balance headline with income / expenses / savings stat cards
- **Weekly spending bar chart** with today highlighted
- **Category breakdown donut chart** with color-coded legend
- Horizontal-scroll **savings goals carousel** with animated cards
- **Recent transactions** preview with "See All" → jumps to Transactions tab
- "Needs attention" card (over-budget categories, broken streaks)

### Transaction Tracking
- Add / edit / delete transactions with amount, category, date, and note
- **Income vs Expense toggle** swaps the category grid picker accordingly
- **Search** by note text + filter by type and category
- **Grouped by date**: Today, Yesterday, This Week, Earlier
- **Swipe actions** for quick edit and delete
- **Floating action button** for fast entry from any scroll position
- Confirmation dialog on delete to prevent accidental taps

### Savings Goals
- Create goals with name, target amount, deadline, and SF Symbol icon
- **Animated circular progress ring** that fills as you contribute
- **Contribution history** — each "add funds" is recorded as a dated entry
- **Active vs Completed** sections
- Goal carousel with swipe-to-next animation and subtle sound effect
- Edit and delete with confirmation

### No-Spend Challenge
- Set a target number of days for a no-spend streak
- **Calendar grid** visualization: green = no spend, red = streak broken
- **Current streak** counter with flame icon + **Personal Best**
- **Configurable exempt categories** — recurring bills don't break your streak
- Motivational messages at milestones (7, 14, 30 days)
- Streak is recomputed live from transaction history (no manual check-in)

### Budget Tracking
- Set **monthly spending limits** per category
- **Color-coded progress bars**: blue → orange at 80% → red at 100%+
- **Over-budget warnings** surface on the Dashboard
- Context menu delete with confirmation
- Budgets reset naturally each month based on transaction dates

### Insights
- **Top spending category** with month-over-month % change
- **Weekly comparison** bar chart (this week vs last week)
- **6-month trend** line chart (income vs expense)
- **Category ranking** horizontal bar chart
- Quick stats: average daily spend · most frequent category · biggest expense · days since last income

### Settings & Extras
- **Biometric lock** (FaceID / TouchID) with graceful fallback if unavailable
- **CSV export** via system share sheet
- **User profile name** (used in greeting)
- **Currency picker** (formatting follows device locale, symbol overridable)
- **Reset all data** with double confirmation
- **3-page onboarding** shown once on first launch

---

## Architecture

```
Views (SwiftUI)
  ↓ @State, @Binding
ViewModels (@Observable)
  ↓ method calls
Services (struct, stateless)
  ↓ ModelContext
SwiftData Models (@Model)
```

**Key architectural decisions:**

| Decision | Rationale |
|---|---|
| **`@Observable` over `ObservableObject`** | Less boilerplate, finer-grained change tracking, modern Swift idiom. |
| **SwiftData over Core Data** | Native Swift, automatic schema migration, macro-based models, cleaner API. |
| **Struct services with injected `ModelContext`** | Stateless, trivially testable, no singleton overhead, clear dependency flow. |
| **String raw values on enums** | SwiftData-compatible, human-readable in storage, forward-compatible if cases are added. |
| **In-memory filtering over complex predicates** | Responsive UI, simpler code, perfectly adequate for local single-user data sizes. |
| **Component-first UI** | Reusable SwiftUI views (`StatCardView`, `CircularProgressView`, `FilterChipView`, etc.) keep screens thin. |

---

## Project Structure

```
PersonalFinance/
├── Models/
│   ├── Transaction.swift          # Core transaction model
│   ├── TransactionType.swift      # Income / expense enum
│   ├── Category.swift             # 12 categories with icons & colors
│   ├── SavingsGoal.swift          # Goal with progress tracking
│   ├── GoalContribution.swift     # Individual fund additions (history)
│   ├── NoSpendChallenge.swift     # Streak challenge model
│   ├── Budget.swift               # Monthly category budget
│   └── CurrencyOption.swift       # Currency picker options
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── TransactionListViewModel.swift
│   ├── AddTransactionViewModel.swift
│   ├── GoalsListViewModel.swift
│   ├── GoalDetailViewModel.swift
│   ├── AddGoalViewModel.swift
│   ├── ChallengeViewModel.swift
│   ├── BudgetViewModel.swift
│   ├── InsightsViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Common/       # MainTabView, EmptyStateView, LockScreenView
│   ├── Dashboard/    # DashboardView
│   ├── Transactions/ # TransactionListView, AddTransactionView
│   ├── Goals/        # GoalsListView, GoalDetailView, AddGoalView,
│   │                 # ChallengeView, BudgetListView
│   ├── Insights/     # InsightsView
│   ├── Settings/     # SettingsView, CurrencyPickerView
│   └── Onboarding/   # OnboardingView
├── Services/
│   ├── TransactionService.swift   # CRUD + filtering
│   ├── GoalService.swift
│   ├── ContributionService.swift  # Atomic add/remove funds
│   ├── ChallengeService.swift     # Streak computation + calendar
│   ├── BudgetService.swift
│   ├── MockDataService.swift      # Seeds realistic sample data
│   ├── BiometricService.swift     # FaceID / TouchID wrapper
│   └── ExportService.swift        # CSV generation
├── Components/
│   ├── FilterChipView.swift
│   ├── CategoryGridView.swift
│   ├── TransactionRowView.swift
│   ├── StatCardView.swift
│   ├── SectionHeaderView.swift
│   ├── GoalCardView.swift, GoalCarouselView.swift, GoalCarouselCardView.swift
│   ├── CircularProgressView.swift
│   ├── StreakCalendarView.swift
│   ├── BudgetProgressRow.swift, BudgetGridCard.swift, BudgetFillCard.swift
│   ├── NeedsAttentionCard.swift
│   ├── ProgressTimelineView.swift
│   ├── CarouselPageIndicator.swift
│   ├── PresetChipRow.swift
│   └── AnimationUtilities.swift
├── Extensions/
│   ├── Date+Extensions.swift
│   ├── Double+Currency.swift
│   ├── Color+Theme.swift
│   └── AppTypography.swift
└── PersonalFinanceApp.swift       # App entry + SwiftData container config
```

---

## Data Model

```
Transaction          SavingsGoal ── 1:N ── GoalContribution
  amount: Double       name: String              amount: Double
  type: .income/.expense  targetAmount: Double    date: Date
  category: Category   deadline: Date?           note: String?
  date: Date           iconName: String
  note: String?        isCompleted: Bool

NoSpendChallenge     Budget
  startDate: Date      category: Category
  targetDays: Int      monthlyLimit: Double
  bestStreak: Int      month: Date
  exemptCategories     
```

All models use `@Model` (SwiftData). The 12 categories (food, transport, entertainment, bills, shopping, health, education, salary, freelance, investment, gift, other) each carry an SF Symbol icon and a theme color.

---

## UX Polish

- **Delete confirmations** on all destructive actions
- **Keyboard "Done" toolbar** on all numeric/text inputs
- **Haptic feedback** on saves, deletes, tab switches, and filter selections
- **Loading states** with `ProgressView` on data-heavy screens
- **Empty states** with fade-in animation and actionable CTAs
- **Accessibility labels** on charts, progress bars, and custom components
- **Dark Mode** supported via adaptive system colors
- **Smooth animations** on goal cards, streak counters, and progress fills
- **Sound effects** on goal carousel swipes (subtle, mutable)

---

## Assumptions & Limitations

**Assumptions:**
- Single user per device — no multi-profile support.
- Offline-only — no CloudKit, no backend sync, no account required.
- Currency formatting follows device locale; the user can override the symbol but amounts are stored as plain `Double` (no multi-currency conversion).
- Monthly analytics assume a calendar-month boundary (not rolling 30 days).
- The no-spend challenge is derived from transaction history — the user doesn't "check in" daily; logging a non-exempt expense breaks the streak.
- Mock data seeds only when the database is empty (first launch or after Reset).

**Limitations:**
- No iPad-optimized layout (portrait iPhone is the design target).
- No import from bank CSV / OFX (export only).
- No recurring-transaction automation (each transaction is logged manually).
- Insights trends cap at **6 months** of history.
- Biometric availability depends on device hardware and enrollment — the app falls back to a passcode-free unlocked state if disabled.
- No unit/UI test suite in the current build.

---

## Roadmap / Possible Extensions

- iCloud/CloudKit sync for multi-device support
- Recurring transactions (rent, subscriptions, salary auto-post)
- Custom user-defined categories with emoji picker
- Widget (home-screen spending summary)
- Apple Watch companion for quick expense logging
- Import from bank CSV / Apple Wallet
- Localization beyond device locale (i18n strings)
- Unit tests for services, snapshot tests for components
