import 'package:flutter_riverpod/flutter_riverpod.dart';

class FABActionNotifier extends StateNotifier<void Function()?> {
  FABActionNotifier() : super(null);

  void setAction(void Function()? action) {
    state = action;
  }
}

final fabActionProvider = StateNotifierProvider<FABActionNotifier, void Function()?>( (ref) => FABActionNotifier());
