# System Instructions: Project Wallet (Paisa Clone)

## 1. Project Overview
Build a premium, offline-first personal finance dashboard for Android 14. The app allows users to monitor their financial health, view transaction history, manage accounts (wallets), and track spending visually. The app must feel fluid, tactile, and native.

## 2. Technical Stack & Libraries
* **UI Framework:** Jetpack Compose (Material 3)
* **Architecture:** MVVM (Model-View-ViewModel) with strict Unidirectional Data Flow.
* **Database:** Room Database (SQLite) with Kotlin Coroutines & Flow for reactive UI.
* **Navigation:** `androidx.navigation:navigation-compose`
* **Dependency Injection:** Manual (Custom ViewModelProviders) to save compilation memory. Do not use Hilt/Dagger.
* **Charts:** Native Compose `Canvas` (avoid heavy 3rd-party charting libraries to minimize APK bloat and memory usage).

## 3. Data Model (Room Entities)

### AccountEntity

```kotlin
@Entity(tableName = "accounts")
data class AccountEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String, // e.g., "Cash", "Bank"
    val initialBalance: Double,
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "transactions", 
    foreignKeys = [ForeignKey(entity = AccountEntity::class, parentColumns = ["id"], childColumns = ["accountId"])]
)
```

### TransactionEntity

```kotlin
data class TransactionEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val accountId: Long,
    val amount: Double,
    val type: String, // "Income" or "Expense"
    val note: String,
    val category: String, // e.g., "Food", "Salary"
    val dateMillis: Long = System.currentTimeMillis()
)
```

## 4. UI/Screen Structure

* Top App Bar (Global)
* Placeholder profile icon (Left)
* Greeting Text "Good evening, [User]"
* Premium Badge/Icon (Right)
* Dashboard (HomeScreen)
  
* **Total Balance Card:** Massive balance display, eye icon to hide balance, "This month" breakdown for Income/Expense with percentage indicators.

* **Overview Grid:** LazyVerticalGrid (2 columns) showing summary cards for Budgets, Assets, Bill Splitter, and Loans.

* **Ledger (AccountsScreen):**
LazyColumn listing all transactions.

Transaction Item: Icon, Note, Date, Amount (Green for Income, Red for Expense).

Swipe-to-Dismiss functionality for deletion.

Input Form (AddTransactionScreen)
Material 3 SingleChoiceSegmentedButtonRow for Income/Expense toggle.

Numeric OutlinedTextField for Amount.

Text OutlinedTextField for Note.

Category Selector (Dropdown or BottomSheet).

Save Button (transforms into CircularProgressIndicator while saving).

Analytics (ReportsScreen)
Native Compose Donut Chart showing Expense vs. Income ratio.

<br>

## Breakdown list of spending by category.

### 1. Execution Roadmap & Rules
**Rule:** You will execute this project phase by phase. Do not build the entire app at once. Before starting a phase, read the existing project files. If a phase is already clearly implemented and fully functional, acknowledge it and skip to the next.

**Search Rule:** Always use the internet to search https://developer.android.com/reference/kotlin/androidx/compose/material3/ to fetch the most up-to-date syntax for M3 components before implementing them.

<br>

Phase 1: The Engine - Implement Room Database, Entities, and DAOs.

Phase 2: The Skeleton - Implement Jetpack Navigation Compose and the Bottom Navigation Bar.

Phase 3: The Dashboard - Build HomeScreen and map it to WalletViewModel StateFlows.

Phase 4: The Ledger - Build AccountsScreen history list.

Phase 5: The Input Pipeline - Build AddTransactionScreen and wire data insertion.

Phase 6: Visualizations - Implement native Canvas charts in ReportsScreen.

# context-mode — MANDATORY routing rules

You have context-mode MCP tools available. These rules are NOT optional — they protect your context window from flooding. A single unrouted command can dump 56 KB into context and waste the entire session.

## BLOCKED commands — do NOT attempt these

### curl / wget — BLOCKED
Any shell command containing `curl` or `wget` will be intercepted and blocked. Do NOT retry.
Instead use:
- `mcp__context-mode__ctx_fetch_and_index(url, source)` to fetch and index web pages
- `mcp__context-mode__ctx_execute(language: "javascript", code: "const r = await fetch(...)")` to run HTTP calls in sandbox

### Inline HTTP — BLOCKED
Any shell command containing `fetch('http`, `requests.get(`, `requests.post(`, `http.get(`, or `http.request(` will be intercepted and blocked. Do NOT retry with shell.
Instead use:
- `mcp__context-mode__ctx_execute(language, code)` to run HTTP calls in sandbox — only stdout enters context

### WebFetch / web browsing — BLOCKED
Direct web fetching is blocked. Use the sandbox equivalent.
Instead use:
- `mcp__context-mode__ctx_fetch_and_index(url, source)` then `mcp__context-mode__ctx_search(queries)` to query the indexed content

## REDIRECTED tools — use sandbox equivalents

### Shell (>20 lines output)
Shell is ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`, and other short-output commands.
For everything else, use:
- `mcp__context-mode__ctx_batch_execute(commands, queries)` — run multiple commands + search in ONE call
- `mcp__context-mode__ctx_execute(language: "shell", code: "...")` — run in sandbox, only stdout enters context

### read_file (for analysis)
If you are reading a file to **edit** it → read_file is correct (edit needs content in context).
If you are reading to **analyze, explore, or summarize** → use `mcp__context-mode__ctx_execute_file(path, language, code)` instead. Only your printed summary enters context.

## 8. The Synchronization Protocol (CRITICAL)
Whenever you successfully implement a new feature, UI change, or database alteration in this Jetpack Compose project, you MUST perform the following two steps before finishing your response:
1. Open `D:\Ideas\Antigravity\Wallet\SPEC.md` and update it to reflect the new reality of the app (e.g., check off boxes in the Feature Parity Checklist, update the Data Model tables, or add new UI specs).
2. Copy the newly updated `SPEC.md` file and overwrite the exact same file located at `D:\Ideas\Antigravity\Wallet-Flutter\SPEC.md` so the Flutter project stays in perfect sync. You can use a terminal command to copy the file over.

**CRITICAL RULE:** Always check and always update the SPEC.md file in BOTH the repositories (Wallet and Wallet-Flutter) whenever any changes are made.

### grep / search (large results)
Search results can flood context. Use `mcp__context-mode__ctx_execute(language: "shell", code: "grep ...")` to run searches in sandbox. Only your printed summary enters context.

## Tool selection hierarchy

1. **GATHER**: `mcp__context-mode__ctx_batch_execute(commands, queries)` — Primary tool. Runs all commands, auto-indexes output, returns search results. ONE call replaces 30+ individual calls.
2. **FOLLOW-UP**: `mcp__context-mode__ctx_search(queries: ["q1", "q2", ...])` — Query indexed content. Pass ALL questions as array in ONE call.
3. **PROCESSING**: `mcp__context-mode__ctx_execute(language, code)` | `mcp__context-mode__ctx_execute_file(path, language, code)` — Sandbox execution. Only stdout enters context.
4. **WEB**: `mcp__context-mode__ctx_fetch_and_index(url, source)` then `mcp__context-mode__ctx_search(queries)` — Fetch, chunk, index, query. Raw HTML never enters context.
5. **INDEX**: `mcp__context-mode__ctx_index(content, source)` — Store content in FTS5 knowledge base for later search.

## Output constraints

- Keep responses under 500 words.
- Write artifacts (code, configs, PRDs) to FILES — never return them as inline text. Return only: file path + 1-line description.
- When indexing content, use descriptive source labels so others can `search(source: "label")` later.

## ctx commands

| Command | Action |
|---------|--------|
| `ctx stats` | Call the `stats` MCP tool and display the full output verbatim |
| `ctx doctor` | Call the `doctor` MCP tool, run the returned shell command, display as checklist |
| `ctx upgrade` | Call the `upgrade` MCP tool, run the returned shell command, display as checklist |
