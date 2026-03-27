import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/database/providers.dart';

class AuthState {
  final bool isLocked;
  final bool canCheckBiometrics;
  final bool isBiometricEnabled;

  AuthState({
    required this.isLocked,
    required this.canCheckBiometrics,
    required this.isBiometricEnabled,
  });

  AuthState copyWith({
    bool? isLocked,
    bool? canCheckBiometrics,
    bool? isBiometricEnabled,
  }) {
    return AuthState(
      isLocked: isLocked ?? this.isLocked,
      canCheckBiometrics: canCheckBiometrics ?? this.canCheckBiometrics,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final LocalAuthentication _auth = LocalAuthentication();
  static const _keyBiometric = 'is_biometric_enabled';

  @override
  AuthState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isEnabled = prefs.getBool(_keyBiometric) ?? false;
    
    // Check capabilities in background
    Future.microtask(() => _checkCapabilities());
    
    return AuthState(
      isLocked: isEnabled, 
      canCheckBiometrics: false,
      isBiometricEnabled: isEnabled,
    );
  }

  Future<void> _checkCapabilities() async {
    bool canCheck = false;
    try {
      canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {}
    
    state = state.copyWith(canCheckBiometrics: canCheck);
    
    // Auto-authenticate if locked
    if (state.isLocked) {
      await authenticate();
    }
  }

  Future<void> toggleBiometric(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_keyBiometric, value);
    state = state.copyWith(isBiometricEnabled: value);
  }

  void setLocked(bool value) {
    state = state.copyWith(isLocked: value);
  }

  Future<bool> authenticate() async {
    if (!state.isBiometricEnabled) {
      state = state.copyWith(isLocked: false);
      return true;
    }
    
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to unlock Wallet',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows PIN fallback which is more reliable
          useErrorDialogs: true,
        ),
      );
      if (authenticated) {
        state = state.copyWith(isLocked: false);
      }
      return authenticated;
    } catch (e) {
      return false;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
