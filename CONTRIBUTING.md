# 🤝 Contributing to Project Wallet

Thank you for your interest in contributing to **Project Wallet**! We welcome contributions that help make this personal finance dashboard even better. 🏦✨

---

## ✨ Contribution Flow

1.  **🍴 Fork the repository** on GitHub.
2.  **📥 Clone** your fork locally.
3.  **🌿 Create a branch** for your feature or bugfix:
    ```bash
    git checkout -b feature/amazing-feature
    ```
4.  **💻 Make your changes**.
5.  **🧹 Run analysis and tests** to ensure no regressions:
    ```bash
    flutter analyze
    flutter test
    ```
6.  **💾 Commit** your changes with a clear message:
    ```bash
    git commit -m 'feat: add amazing feature'
    ```
7.  **🚀 Push** to your branch:
    ```bash
    git push origin feature/amazing-feature
    ```
8.  **Pull Request**: Open a PR on the main repository! 📩

---

## 🛠️ Development Setup

1.  **🩺 Health Check**: Ensure Flutter is installed and healthy.
    ```bash
    flutter doctor -v
    ```
2.  **🏗️ Dependencies**: Install necessary packages.
    ```bash
    flutter pub get
    ```
3.  **⚙️ Code Generation**: Run this for Isar and Riverpod files.
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
4.  **🧪 Verify**: Ensure the codebase is clean.
    ```bash
    flutter analyze
    ```
5.  **▶️ Run**: Start the application.
    ```bash
    flutter run
    ```

---

## ✅ Pull Request Checklist

- [ ] Code is formatted and lint-clean (`flutter analyze`). 🧹
- [ ] Existing tests pass (`flutter test`). 🧪
- [ ] New logic includes unit tests where practical. 🧩
- [ ] Documentation (`SPEC.md` or `CHANGELOG.md`) is updated. 📜
- [ ] UI changes follow Material 3 Expressive guidelines. 🎨

---

## 🎯 Code Style

- **Strict M3**: Only use Material 3 components (`useMaterial3: true`).
- **Clean Architecture**: Business logic in Services, UI in Pages/Widgets. 🏛️
- **Surgical Rebuilds**: Use Riverpod `.select()` for performance. ⚡
- **Immutability**: Prefer `const` widgets and immutable state. 🔒

---

## 🐞 Issue Reporting

If you find a bug or have a feature request, please open an issue in the repository. Provide as much detail as possible, including device info and screenshots if applicable. 📸

---
*Built with ❤️ for the Flutter Community.* 💼
