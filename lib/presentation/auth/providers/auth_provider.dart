import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _init();
    return AuthState(
      isLocked: false, 
      canCheckBiometrics: false,
      isBiometricEnabled: false,
    );
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_keyBiometric) ?? false;
    
    bool canCheck = false;
    try {
      canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {}
    
    state = state.copyWith(
      canCheckBiometrics: canCheck,
      isBiometricEnabled: isEnabled,
      isLocked: isEnabled,
    );

    // If locked, try to authenticate automatically
    if (state.isLocked) {
      await authenticate();
    }
  }

  Future<void> toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
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
