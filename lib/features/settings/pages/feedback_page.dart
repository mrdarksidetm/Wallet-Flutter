import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/primary_atelier_button.dart';
import '../../../core/widgets/app_back_button.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'Feedback',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help us refine the experience.',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
            const SizedBox(height: 8),
            Text(
              'Your thoughts help us continuously push the boundaries of offline personal finance UI.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name (Optional)',
                      prefixIcon: const Icon(Symbols.person_rounded),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email (Optional)',
                      prefixIcon: const Icon(Symbols.alternate_email_rounded),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      hintText: 'Share your feedback, bug report, or feature idea...',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 76),
                        child: Icon(Symbols.rate_review_rounded),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            PrimaryAtelierButton(
              onPressed: () async {
                final email = _emailController.text;
                final message = _messageController.text;

                if (message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a message')),
                  );
                  return;
                }

                // Robust Email Regex
                final emailRegex = RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                );

                if (email.isNotEmpty && !emailRegex.hasMatch(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid email address')),
                  );
                  return;
                }

                

                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'contact.dsidetm+walletf@gmail.com',
                  query: encodeQueryParameters({
                    'subject': 'Wallet App Feedback',
                    'body':
                        'Name: ${_nameController.text}\nEmail: $email\n\n$message',
                  }),
                );

                try {
                  await launchUrl(emailLaunchUri);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Feedback prepared! Please send via your email app.')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open email app: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Symbols.send, color: Colors.white),
              label: const Text('Send Feedback'),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
