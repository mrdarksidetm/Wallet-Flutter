import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../budgets/presentation/add_budget_screen.dart';
import '../../budgets/presentation/budget_details_screen.dart';
import 'widgets/budget_components.dart';
import 'controllers/budget_controller.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    
    final budgetsAsync = ref.watch(budgetControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F2), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Budgets',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            color: const Color(0xFF1B1B1F),
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF90594C), // Terracotta pill
              borderRadius: BorderRadius.circular(16),
            ),
            // Show active budget count out of total (mocked to just total length for now)
            child: budgetsAsync.maybeWhen(
              data: (budgets) => Text('${budgets.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              orElse: () => const Text('...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF1B1B1F)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: budgetsAsync.when(
        data: (budgets) {
           if (budgets.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Color(0xFFD3BDB9)),
                   const SizedBox(height: 16),
                   Text('No budgets yet', style: textTheme.titleLarge?.copyWith(color: const Color(0xFF5A4D48))),
                   const SizedBox(height: 8),
                   const Text('Tap the + button to create one', style: TextStyle(color: Color(0xFF8A7773))),
                 ],
               ),
             );
           }
           
           return ListView.separated(
             padding: const EdgeInsets.all(16.0),
             itemCount: budgets.length,
             separatorBuilder: (context, index) => const SizedBox(height: 16),
             itemBuilder: (context, index) {
               final budget = budgets[index];
               return BudgetCard(
                 budget: budget,
                 onTap: () => Navigator.push(
                   context, 
                   MaterialPageRoute(builder: (_) => BudgetDetailsScreen(budget: budget)),
                 ),
               );
             },
           );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF945B50))),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        backgroundColor: const Color(0xFF945B50), // Terracotta FAB
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBudgetScreen()));
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
