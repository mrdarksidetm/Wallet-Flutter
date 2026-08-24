# The Expressive Architecture Update 🎨
Welcome to **v4.0.5** of **Wallet**! 🎉

This milestone release brings a massive visual, structural, and architectural overhaul to Wallet. We've elevated the application with authentic Material 3 Expressive connected layouts, unified navigation ergonomics, a reimagined settings and personalization studio, full toolchain stabilization, and enhanced offline-first data reliability.

---

## ✨ What's Changed

### 🎨 Material 3 Expressive UI & Connected Layouts
* **OVERHAULED** transaction listings with `TransactionSegmentedGroup`: connected cards with adaptive squircle geometry (28dp outer corners, 4dp inner dividers) unified across Home, All Transactions, Category Details, Account Details, and Person Details.
* **REFINED** the **Activity Heatmap Calendar** with contrast-aware white text for days with recorded transactions, ensuring flawless legibility across all dynamic theme palettes.
* **STANDARDIZED** a universal `AppBackButton` (40x40 squircle badge with tonal background and haptics) and flexible medium AppBars with `scrolledUnderElevation: 3.0` across the entire app.
* **ENFORCED** hierarchical back navigation to ensure predictable navigation back to Home without dead-ends.
* **ENHANCED** category icon presentations with soft tonal squircle background shapes and harmonic tokens.

### ⚙️ Modular Settings & Personalization Studio
* **REVAMPED** Settings into modular categories: **General**, **Personalization**, **Backup & Restore**, **Privacy & Security**, and **About**.
* **INTRODUCED** `SettingsSegmentedCard` for grouped, connected M3/Cupertino-style configuration cards.
* **ADDED** live search filtering across all settings pages with smooth auto-scrolling.
* **REBUILT** the **Personalization Page** featuring:
  * Connected Theme Mode selector (System, Light, Dark).
  * Dynamic 3-segment color palette previews (`_PalettePainter`) visualizing Primary, Secondary, and Tertiary swatches.
  * Compact S-size sliders with real-time numeric value bubble badges.
  * Interactive typography selector with `Google Sans Flex` preview and instant 1-tap "Reset to Defaults".
* **ENHANCED** Developer Profile on the About page with GitHub & Email pill action buttons.
* **ADDED** a secret 7-tap Easter Egg on the version badge to unlock the Developer Error Collector / LogCat console.

### 🤝 Loans & People Management
* **ADDED** collapsible section toggles for Lent and Borrowed loan groups.
* **CLIPPED** swipe-to-delete/action backgrounds to clean pill shapes.
* **STREAMLINED** person avatar associations and direct in-transaction contact creation.

### 🛡️ Core Reliability, Architecture & Security
* **STABILIZED** Isar persistence layer with stream link hydration, UUID preservation, and lifecycle memory safety.
* **EXPANDED** comprehensive offline-first **Privacy Policy** and **Terms of Use** documents.
* **RESOLVED** Dependabot security alerts and configured CodeQL security analysis workflows.

### 🚀 CI/CD Pipeline & Android Toolchain
* **SYNCHRONIZED** Android build toolchain with AGP 8.11.1 / 8.13.0 and Gradle 8.11.1 / 8.14.5 targeting SDK 35/36.
* **STABILIZED** multi-ABI APK builds (`arm64-v8a`, `armeabi-v7a`, and `Universal`) in GitHub Actions with robust fallback keystore generation, alias detection, and PKCS12 verification.
* **ENHANCED** CI transparency with direct error annotations and dynamic recursive APK preservation.

---

> [!NOTE]
> Developer tools (such as the LogCat Error Collector) can now be toggled via the 7-tap version badge gesture on the About page. Both Universal and Split APKs (`arm64-v8a`, `armeabi-v7a`) are fully generated and validated! 🥳

---

> [!IMPORTANT]
> Always use the **Backup Database** feature in `Settings > Backup & Restore` to export your data to a `.zip` archive before updating.

---

## 📦 Download Assets & Architecture Guide

To ensure optimal performance and minimize download size for your specific device, download the package matching your Android architecture:

| Architecture | Asset Name | Description |
| :--- | :--- | :--- |
| **ARM64 (64-bit)** | `wallet-arm64-v8a.apk` | **Highly Recommended** for modern Android devices (2016+). Offers optimal performance, memory efficiency, and the smallest file size. |
| **ARM32 (32-bit)** | `wallet-arm-v7a.apk` | Intended for older, budget, or legacy 32-bit Android devices. |
| **Universal (Fat APK)** | `wallet-universal.apk` | Contains binaries for both 32-bit and 64-bit devices. Compatible with all Android devices. |

---

*Created with ❤️ by mrdarksidetm*

**Full Changelog**: https://github.com/mrdarksidetm/Wallet-Flutter/compare/v3.1.0...v4.0.5
