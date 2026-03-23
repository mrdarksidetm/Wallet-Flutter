# Contributing to Wallet

Thank you for your interest in contributing to Wallet! We welcome contributions from the community to help make this project better.

## ✨ Contribution Flow

1. **Fork the repository** on GitHub.
2. **Clone** your fork locally.
3. **Create a branch** for your feature or bugfix (`git checkout -b feature/amazing-feature`).
4. **Make your changes**.
5. **Run analysis and tests** to ensure no regressions.
   - `flutter analyze`
   - `flutter test`
6. **Commit** your changes (`git commit -m 'Add some amazing feature'`).
7. **Push** to your branch (`git push origin feature/amazing-feature`).
8. **Open a Pull Request**.

## 🛠️ Development Setup

1. Ensure Flutter is installed and environment is healthy.
   - `flutter doctor -v`
2. Clone the repo with submodules.
   - `git clone --recursive https://github.com/mrdarksidetm/Wallet.git`
   - `cd Wallet`
3. Install dependencies.
   - `flutter pub get`
4. Run code generation (required for Isar and Riverpod generated files).
   - `dart run build_runner build --delete-conflicting-outputs`
5. Run static analysis.
   - `flutter analyze`
6. Run tests.
   - `flutter test`
7. Run the app.
   - `flutter run`

## ✅ Pull Request Checklist

- [ ] Code is formatted and lint-clean (`flutter analyze`)
- [ ] Existing tests pass (`flutter test`)
- [ ] New logic includes tests where practical
- [ ] Documentation is updated if behavior changed

## 🧪 Testing Notes

- Current automated coverage is still growing.
- A focused test suite is available at `test/features/insights/financial_insight_service_test.dart`.
- `test/widget_test.dart` is currently a placeholder smoke test because app-level integration requires additional mocking around storage and startup dependencies.
- If your change touches business logic, add or extend unit tests in the related feature module.

## 🎯 Code Style

- Follow standard Flutter linting rules.
- Keep code clean and documented where necessary.
- Use `flutter optimize_imports` if available, or just standard IDE formatting.

## 🐞 Issue Reporting

If you find a bug or have a feature request, please open an issue in the repository. Provide as much detail as possible.

## 📚 Related Docs

- Project overview and setup quickstart: [README.md](README.md)
- Full feature and model specification: [SPEC.md](SPEC.md)
- Security policy: [SECURITY.md](SECURITY.md)
