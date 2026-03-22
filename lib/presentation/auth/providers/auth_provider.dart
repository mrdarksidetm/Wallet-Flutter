import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

class AuthState {
  final bool isLocked;
  final bool canCheckBiometrics;

  AuthState({required this.isLocked, required this.canCheckBiometrics});

  AuthState copyWith({bool? isLocked, bool? canCheckBiometrics}) {
    return AuthState(
      isLocked: isLocked ?? this.isLocked,
      canCheckBiometrics: canCheckBiometrics ?? this.canCheckBiometrics,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LocalAuthentication _auth = LocalAuthentication();

  AuthNotifier() : super(AuthState(isLocked: false, canCheckBiometrics: false)) {
    _init();
  }

  Future<void> _init() async {
    final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    state = state.copyWith(canCheckBiometrics: canCheck);
  }

  void setLocked(bool value) {
    state = state.copyWith(isLocked: value);
  }

  Future<bool> authenticate() async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to unlock Wallet',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
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
