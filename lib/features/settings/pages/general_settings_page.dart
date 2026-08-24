import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/widgets/app_back_button.dart';
import '../widgets/settings_segmented_card.dart';

class GeneralSettingsPage extends ConsumerWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final personalization = ref.watch(personalizationProvider);
    final currency = ref.watch(currencyProvider);
    final fillIcons = personalization.fillIcons;

    final hasValidPhoto = personalization.userPhoto != null &&
        File(personalization.userPhoto!).existsSync();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Medium Flexible Top App Bar with back navigation & enlarged title
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'General',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList.list(
              children: [
                // Profile Overview / Edit Profile Segmented Card
                Material(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/edit_profile'),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            backgroundImage: hasValidPhoto
                                ? FileImage(File(personalization.userPhoto!))
                                : null,
                            child: !hasValidPhoto
                                ? Icon(
                                    Symbols.person,
                                    size: 30,
                                    color: colorScheme.onSurfaceVariant,
                                    fill: fillIcons ? 1.0 : 0.0,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (personalization.userName == null ||
                                          personalization.userName!.isEmpty)
                                      ? 'Your Profile'
                                      : personalization.userName!,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to edit name and profile photo',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            onPressed: () => context.push('/edit_profile'),
                            icon: const Icon(Symbols.edit_rounded, size: 16),
                            label: const Text('Edit'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Currency and Category Segmented Group
                SettingsSegmentedGroup(
                  children: [
                    SettingsActionTile(
                      icon: Symbols.currency_exchange_rounded,
                      title: 'Currency Settings',
                      subtitle: 'Current currency: $currency',
                      showDivider: true,
                      onTap: () {
                        context.push('/currency_selection');
                      },
                    ),
                    SettingsActionTile(
                      icon: Symbols.category_rounded,
                      title: 'Categories',
                      subtitle: 'Organize transaction labels & icons',
                      showDivider: true,
                      onTap: () {
                        context.push('/categories');
                      },
                    ),
                    SettingsActionTile(
                      icon: Symbols.rate_review_rounded,
                      title: 'Send Feedback',
                      subtitle: 'Share your thoughts and ideas',
                      showDivider: false,
                      onTap: () {
                        context.push('/feedback');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
