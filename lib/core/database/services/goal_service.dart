import 'package:isar/isar.dart';
import '../models/auxiliary_models.dart';
import '../repositories/finance_repositories.dart';

class GoalService {
  final Isar isar;
  final GoalRepository goalRepository;

  GoalService({required this.isar, required this.goalRepository});

  Future<void> addGoal({
    required String name,
    required double targetAmount,
    required DateTime deadline,
    required String color,
    String? icon,
  }) async {
    await isar.writeTxn(() async {
      final goal = Goal()
        ..name = name
        ..targetAmount = targetAmount
        ..currentAmount = 0.0
        ..deadline = deadline
        ..color = color
        ..icon = icon
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
        
      await isar.goals.put(goal);
    });
  }

  Future<void> saveGoal(Goal goal) async {
    await isar.writeTxn(() async {
      if (goal.currentAmount >= goal.targetAmount) {
        goal.isCompleted = true;
      } else {
        goal.isCompleted = false;
      }
      await isar.goals.put(goal);
    });
  }

  Future<void> updateAmount(Goal goal, double newAmount) async {
    await isar.writeTxn(() async {
      goal.currentAmount = newAmount;
      goal.updatedAt = DateTime.now();
      if (goal.currentAmount >= goal.targetAmount) {
        goal.isCompleted = true;
      } else {
        goal.isCompleted = false;
      }
      await isar.goals.put(goal);
    });
  }

  Future<void> deleteGoal(Id id) async {
    await goalRepository.delete(id);
  }
}
