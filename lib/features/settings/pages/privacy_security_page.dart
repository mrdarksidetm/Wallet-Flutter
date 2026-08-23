import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:restart_app/restart_app.dart';
import '../../../core/services/data_shredder.dart';
import '../../../core/database/providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/settings_segmented_card.dart';

class PrivacySecuritySettingsPage extends ConsumerWidget {
  const PrivacySecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Medium Flexible Top App Bar with back navigation & enlarged title
          SliverAppBar.medium(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Symbols.arrow_back_rounded),
            ),
            title: Text(
              'Privacy & Security',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Security Controls Group
                SettingsSegmentedGroup(
                  children: [
                    SettingsActionTile(
                      icon: authState.isBiometricEnabled
                          ? Symbols.fingerprint_rounded
                          : Symbols.lock_rounded,
                      title: 'Biometric Lock',
                      subtitle: authState.canCheckBiometrics
                          ? (authState.isBiometricEnabled
                              ? 'App is protected by biometric lock'
                              : 'Require authentication on launch')
                          : 'Biometrics not supported on this device',
                      showDivider: true,
                      trailing: Switch(
                        value: authState.isBiometricEnabled,
                        onChanged: authState.canCheckBiometrics
                            ? (val) async {
                                await ref
                                    .read(authProvider.notifier)
                                    .toggleBiometric(val);
                              }
                            : null,
                      ),
                    ),
                    SettingsActionTile(
                      icon: Symbols.delete_forever_rounded,
                      title: 'Factory Reset',
                      subtitle: 'Permanently wipe all data and reset app',
                      isDestructive: true,
                      showDivider: false,
                      onTap: () => _handleFactoryReset(context, ref),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Privacy & Policy Group
                SettingsSegmentedGroup(
                  children: [
                    SettingsActionTile(
                      icon: Symbols.shield_lock_rounded,
                      title: 'Privacy Policy',
                      subtitle: 'Offline-first data philosophy',
                      showDivider: true,
                      onTap: () {
                        context.push('/privacy_policy');
                      },
                    ),
                    SettingsActionTile(
                      icon: Symbols.policy_rounded,
                      title: 'Terms of Use',
                      subtitle: 'Open source usage terms and conditions',
                      showDivider: false,
                      onTap: () {
                        context.push('/terms_of_use');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFactoryReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Row(
          children: [
            Icon(Symbols.warning_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Factory Reset?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all transactions, accounts, categories, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final isar = ref.read(isarProvider).value;
      if (isar != null) {
        final success = await DataShredder.factoryReset(isar);
        if (success && context.mounted) {
          Restart.restartApp();
        }
      }
    }
  }
}
