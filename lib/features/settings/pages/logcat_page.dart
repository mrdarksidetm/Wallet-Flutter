import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/services/log_service.dart';
import '../../../core/widgets/app_back_button.dart';

class LogcatPage extends ConsumerStatefulWidget {
  const LogcatPage({super.key});

  @override
  ConsumerState<LogcatPage> createState() => _LogcatPageState();
}

class _LogcatPageState extends ConsumerState<LogcatPage> {
  LogLevel? _filterLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allLogs = ref.watch(logServiceProvider);
    
    final logs = _filterLevel == null 
        ? allLogs 
        : allLogs.where((l) => l.level == _filterLevel).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'Error Collector',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Symbols.delete_sweep_rounded),
                onPressed: () {
                  ref.read(logServiceProvider.notifier).clear();
                },
                tooltip: 'Clear Logs',
              ),
              IconButton(
                icon: const Icon(Symbols.content_copy_rounded),
                onPressed: () {
                  final text = logs.map((l) => '[${l.formattedTime}] [${l.level.name.toUpperCase()}] ${l.message}\n${l.stackTrace ?? ""}').join('\n');
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logs copied to clipboard')),
                  );
                },
                tooltip: 'Copy All Logs',
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildFilters(colorScheme),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),
          if (logs.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No logs collected yet.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverList.separated(
                itemCount: logs.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final log = logs.reversed.toList()[index];
                  return _buildLogItem(log, theme, colorScheme);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _filterLevel == null,
              onSelected: (val) => setState(() => _filterLevel = null),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Info'),
              selected: _filterLevel == LogLevel.info,
              onSelected: (val) => setState(() => _filterLevel = val ? LogLevel.info : null),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Performance'),
              selected: _filterLevel == LogLevel.performance,
              onSelected: (val) => setState(() => _filterLevel = val ? LogLevel.performance : null),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Warning'),
              selected: _filterLevel == LogLevel.warning,
              onSelected: (val) => setState(() => _filterLevel = val ? LogLevel.warning : null),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Error'),
              selected: _filterLevel == LogLevel.error,
              onSelected: (val) => setState(() => _filterLevel = val ? LogLevel.error : null),
              selectedColor: colorScheme.errorContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(LogEntry log, ThemeData theme, ColorScheme colorScheme) {
    Color getLogColor() {
      switch (log.level) {
        case LogLevel.error: return colorScheme.error;
        case LogLevel.warning: return Colors.orange;
        case LogLevel.performance: return Colors.purple;
        default: return colorScheme.onSurface;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.formattedTime,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: getLogColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.level.name.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: getLogColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(
            log.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              color: getLogColor(),
            ),
          ),
          if (log.stackTrace != null) ...[
            const SizedBox(height: 4),
            SelectableText(
              log.stackTrace!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: colorScheme.error,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
