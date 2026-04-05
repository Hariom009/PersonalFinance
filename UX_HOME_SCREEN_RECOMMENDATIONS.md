# Home Screen (Dashboard) UX Analysis & Recommendations

> **App:** PersonalFinance (SwiftUI / iOS)
> **File:** `Views/Dashboard/DashboardView.swift` (254 lines)
> **Date:** April 5, 2026

---

## Current State Summary

The dashboard follows a vertical scroll layout:
**Greeting Header** -> **3 Summary Cards** -> **Weekly Spending Chart** -> **Category Donut Chart** -> **Savings Goals (horizontal scroll)** -> **Recent Transactions (5 items)**

Overall it's a clean, well-structured screen. The recommendations below aim to elevate it from "functional" to "delightful and actionable."

---

## 1. Information Architecture Issues

### 1.1 Balance is Misleading Without Context

**Problem:** The hero number (`balance = monthlyIncome - monthlyExpenses`) is labeled "This month's balance," but it's actually just *remaining surplus*, not a true account balance. A user who earned $5,000 and spent $4,800 sees "$200" prominently -- this tells them nothing about their actual financial position.

**Recommendation:**
- Rename to **"This month's net"** or **"Monthly surplus"** to avoid confusion with bank balance.
- Add a subtitle showing the month progress: *"15 of 30 days -- 50% of the month gone, 60% of budget spent"* to create urgency awareness.
- Consider a small trend indicator (arrow up/down + percentage vs. last month) next to the number.

### 1.2 "Saved" Card is Disconnected

**Problem:** The third summary card shows `totalSaved` (sum of all savings goal current amounts). This is a lifetime cumulative number sitting next to two monthly numbers (Income/Expenses). The mental model breaks -- these aren't peers.

**Recommendation:**
- Replace with **"Left to Spend"** = Income - Expenses - (budgeted savings contributions this month). This gives immediate actionable information.
- Or show **"Savings this month"** (amount added to goals this month only).
- Move lifetime savings total to the Savings Goals section header instead.

### 1.3 No Personalization or User Name

**Problem:** The greeting says "Good morning" but doesn't address the user by name. It feels generic rather than personal for a finance app where trust matters.

**Recommendation:**
- Add the user's first name: **"Good morning, Hariom"**
- Store the name during onboarding (you already have an onboarding flow).

---

## 2. Interaction & Navigation Gaps

### 2.1 Dashboard is Read-Only

**Problem:** The entire home screen is passive. There is no quick-add action. To log a transaction, the user must navigate to the Transactions tab, then tap an add button. This adds friction to the most frequent user action.

**Recommendation:**
- Add a **floating action button (FAB)** or a prominent **"+ Add Transaction"** button in the header area.
- Alternatively, add a quick-add bottom sheet triggered from the dashboard -- category picker -> amount -> done.
- Consider a long-press shortcut on the summary cards (e.g., long-press "Expenses" to quickly add an expense).

### 2.2 Charts Are Not Tappable

**Problem:** Both the weekly spending chart and the category donut chart are display-only. Users can't tap a bar to see that day's transactions or tap a category slice to drill into that category.

**Recommendation:**
- **Weekly chart:** Tap a bar -> show a popover or inline expansion listing that day's transactions with amounts.
- **Category chart:** Tap a slice or legend row -> navigate to a filtered transaction list for that category.
- Add `chartOverlay` or `chartGestureTarget` modifiers for tap handling.

### 2.3 Savings Goals Have No Drill-Down

**Problem:** The horizontal goal cards are not wrapped in `NavigationLink`. Users see progress but can't tap to view goal details or add funds.

**Recommendation:**
- Wrap each `GoalCardView` in a `NavigationLink` to a goal detail view.
- Add a **"+ New Goal"** card at the end of the horizontal scroll with a dashed border style.
- Add a "See All" action in the section header (like Recent Transactions has).

### 2.4 No Pull-to-Refresh

**Problem:** Data loads on `.onAppear` only. If a user adds a transaction in another tab and comes back, they must leave and return. There's no manual refresh gesture.

**Recommendation:**
- Add `.refreshable { viewModel.loadData(context: context) }` to the ScrollView.
- Also reload on tab re-selection (detect via `onChange(of: selectedTab)`).

### 2.5 "See All" Only on Transactions

**Problem:** Only the Recent Transactions section has a "See All" action. Savings Goals has no equivalent, creating inconsistency.

**Recommendation:**
- Add "See All" to Savings Goals that navigates to the Goals tab (`selectedTab = 2`).
- Add "See All" or "Details" to the Weekly Spending section that navigates to Insights.
- Maintain consistent navigation patterns across all sections.

---

## 3. Visual Design Improvements

### 3.1 Greeting Header Wastes Vertical Space

**Problem:** The greeting, balance, and subtitle take up significant vertical space with low information density. The greeting adds warmth but pushes content below the fold.

**Recommendation:**
- Collapse into a more compact layout:
  ```
  Good morning           [+ Add]  [Settings]
  $1,200.00  net this month  ^12% vs last month
  ```
- Move the greeting into the navigation bar area or make it a single-line element.
- The balance number can remain large but share a row with the trend indicator.

### 3.2 Summary Cards Get Cramped on Small Screens

**Problem:** Three `StatCardView` cards in an `HStack` with `spacing: 12` can get very tight on iPhone SE / iPhone 14 Mini. Large currency amounts will trigger `minimumScaleFactor` and become unreadable.

**Recommendation:**
- Use a 2+1 layout: two primary cards (Income / Expenses) on top, one full-width card below.
- Or switch to a horizontal scroll for the stat cards.
- Test with 5+ digit amounts (e.g., "$12,345") on the smallest supported screen.

### 3.3 Donut Chart Center is Wasted Space

**Problem:** The donut chart has a 60% inner radius creating a large empty center. This is prime real estate.

**Recommendation:**
- Place the **total expenses** amount in the center of the donut: `$2,450 total`.
- This gives the chart a clear anchor number and makes the proportions immediately meaningful.

### 3.4 Weekly Chart Shows Zero Bars for Future Days

**Problem:** The chart renders all 7 days (Sun-Sat) including future days that show $0 bars. On a Monday, 5 of 7 bars are empty, making the chart look sparse and unhelpful.

**Recommendation:**
- Only show days up to today (or show future days as a faded/dashed placeholder).
- Alternatively, show a rolling "last 7 days" instead of calendar week to always have a full chart.
- Add a daily average line or budget line for reference.

### 3.5 Card Shadows Are Too Subtle

**Problem:** Shadow is `black.opacity(0.04), radius: 8` -- nearly invisible. The cards rely almost entirely on the background color difference for separation. In some lighting / display settings they'll look flat.

**Recommendation:**
- Increase to `opacity(0.06)` or `opacity(0.08)` for better depth perception.
- Or remove shadows entirely and rely on the background contrast (cleaner).
- Choose one strategy and commit -- half-shadows are worse than no shadows.

---

## 4. Data & Content Enhancements

### 4.1 No Budget Awareness on Dashboard

**Problem:** The app has a full budget system (`BudgetProgressRow`, budget features in Insights) but the dashboard shows zero budget information. Users must navigate to Insights to see if they're overspending.

**Recommendation:**
- Add a **budget health indicator** near the top -- a single progress bar or percentage showing "68% of monthly budget used" with color coding (green/orange/red).
- Or integrate budget status into the category legend: show `$200 / $300 budget` next to each category.
- This is the single highest-impact addition for daily utility.

### 4.2 No Time Comparison

**Problem:** All data is current-month only. There's no way to tell if you're doing better or worse than last month.

**Recommendation:**
- Add trend arrows to the summary cards: "Income $5,000 (+8%)" or "Expenses $3,200 (-5%)".
- The weekly chart could show a faded overlay of last week's spending for comparison.
- Even a simple "You've spent 15% less than last month at this point" sentence adds immense value.

### 4.3 Transactions Don't Show Running Total

**Problem:** The recent transactions list shows individual amounts but no running context. Users see "$45 food, $120 rent..." but can't gauge impact.

**Recommendation:**
- Add a subtle cumulative indicator or group transactions by date with a daily total header.
- Consider showing the "time ago" more prominently (e.g., "2h ago" instead of "Today") for recent items to reinforce the recency.

### 4.4 No Recurring Transaction Awareness

**Problem:** There's no indication of upcoming bills or recurring expenses. Users are surprised by charges.

**Recommendation:**
- Add an **"Upcoming"** section (or a single prominent card) showing the next 2-3 recurring bills with due dates.
- Example: `"Rent $1,200 -- due in 3 days"` with a warning color if the balance is insufficient.

---

## 5. Empty & First-Use States

### 5.1 Empty States Are Too Minimal

**Problem:** Empty states are just gray text ("No expenses this month", "No savings goals yet"). For a new user, every section shows an empty state and the screen looks broken/useless.

**Recommendation:**
- Add illustrations or SF Symbol compositions to empty states.
- Include **action prompts**: "No transactions yet -- tap + to add your first one" with a button.
- For savings goals: "Set a savings goal to start tracking your progress" + "Create Goal" button.
- Consider a first-use onboarding card that appears once: "Welcome! Here's how to get started..." with 3 quick actions.

### 5.2 Loading State is a Bare Spinner

**Problem:** `ProgressView()` centered with 100pt top padding. On slow loads, this looks like nothing is happening.

**Recommendation:**
- Use skeleton/shimmer loading states (placeholder shapes mimicking the real layout).
- Or at minimum, add a label: "Loading your finances..."
- The loading should be near-instant for local SwiftData, so consider removing the loading state entirely if `loadData` is synchronous (which it currently is -- there's no async work).

---

## 6. Accessibility & Inclusivity

### 6.1 Color-Only Differentiation

**Problem:** Income (green) vs. Expense (red) relies solely on color. Users with red-green color blindness (8% of males) cannot distinguish them.

**Recommendation:**
- Add directional icons (already done with arrows -- good) but also add "+/-" prefix to amounts.
- Use distinct shapes in addition to colors for the category chart (patterns/hatching in the donut slices).

### 6.2 No Dynamic Type Testing

**Problem:** The 3-column card layout will break at larger Dynamic Type sizes. The `minimumScaleFactor` on amounts will make them unreadable.

**Recommendation:**
- At accessibility text sizes, switch to a vertical stack layout for the summary cards.
- Use `@Environment(\.dynamicTypeSize)` to conditionally change the layout.
- Test with the largest accessibility sizes in the iOS simulator.

### 6.3 Chart Accessibility is Bare Minimum

**Problem:** Charts have basic `accessibilityLabel` but no `accessibilityValue` or structured accessibility for VoiceOver users to navigate individual data points.

**Recommendation:**
- Add `accessibilityLabel` and `accessibilityValue` to each chart mark.
- Provide an "Audio graph" accessibility representation using `.accessibilityChartDescriptor`.
- Add a text-based summary below each chart that VoiceOver can read: "Highest spending was Wednesday at $120. Weekly total: $450."

---

## 7. Performance & Technical

### 7.1 Computed Properties Recalculate on Every Body Evaluation

**Problem:** `monthlyIncome`, `monthlyExpenses`, `weeklySpending`, and `categoryBreakdown` are all computed properties that filter and reduce the full transaction array. Every time any `@Observable` property changes, all of these recompute.

**Recommendation:**
- Cache these values in stored properties and recalculate only in `loadData()`.
- Or use `withAnimation` carefully to avoid unnecessary recomputations.

### 7.2 No Error State

**Problem:** If `loadData` fails (the `catch` block), transactions and goals are silently set to empty arrays. The user sees empty states with no indication that something went wrong.

**Recommendation:**
- Add an `error: String?` property to the ViewModel.
- Show a retry-able error banner: "Couldn't load your data. Tap to retry."

---

## 8. Priority Matrix

| Priority | Recommendation | Impact | Effort |
|----------|---------------|--------|--------|
| **P0** | Add quick-add transaction button | High | Low |
| **P0** | Add budget health indicator | High | Medium |
| **P0** | Fix "Saved" card semantics | High | Low |
| **P1** | Make charts tappable/interactive | High | Medium |
| **P1** | Add trend comparisons (vs last month) | High | Medium |
| **P1** | Savings goals drill-down + "Add Goal" | Medium | Low |
| **P1** | Improve empty/first-use states | Medium | Low |
| **P1** | Add pull-to-refresh | Medium | Low |
| **P2** | Add total in donut center | Medium | Low |
| **P2** | Fix weekly chart future-day bars | Medium | Low |
| **P2** | Add recurring bills / upcoming section | High | High |
| **P2** | Personalize greeting with name | Low | Low |
| **P2** | Compact header layout | Medium | Medium |
| **P3** | Skeleton loading states | Low | Medium |
| **P3** | Dynamic Type layout adaptation | Medium | Medium |
| **P3** | Enhanced chart accessibility | Medium | High |
| **P3** | Cache computed properties | Low | Low |

---

## Summary

The dashboard has a solid foundation -- clean layout, good section hierarchy, proper accessibility labels, and consistent card styling. The biggest gaps are:

1. **Actionability** -- the screen is view-only with no quick actions
2. **Context** -- no budget awareness, no trends, no comparisons
3. **Interactivity** -- charts and goals are not tappable
4. **First-use experience** -- empty states don't guide users

Addressing the P0 items alone (quick-add, budget indicator, fixing the "Saved" card) would significantly improve daily utility.
