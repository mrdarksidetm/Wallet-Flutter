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

class AuthNotifier extends StateNotifier<AuthState> {
  final LocalAuthentication _auth = LocalAuthentication();
  static const _keyBiometric = 'is_biometric_enabled';

  AuthNotifier() : super(AuthState(
    isLocked: false, 
    canCheckBiometrics: false,
    isBiometricEnabled: false,
  )) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_keyBiometric) ?? false;
    final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    
    state = state.copyWith(
      canCheckBiometrics: canCheck,
      isBiometricEnabled: isEnabled,
      isLocked: isEnabled, // Lock by default if enabled
    );
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
          biometricOnly: true,
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

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
