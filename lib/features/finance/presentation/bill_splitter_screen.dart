import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BillSplitterScreen extends ConsumerWidget {
  const BillSplitterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Splitter')),
      body: const Center(
        child: Text('Bill Splitting features coming soon.\nThis will integrate with your People list.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Bill not yet implemented.')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
