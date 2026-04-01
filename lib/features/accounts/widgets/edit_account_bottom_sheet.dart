// This file is deprecated. Please use AddEditAccountPage instead.
// Redirecting to prevent errors while cleanup is in progress.

import 'package:flutter/material.dart';
import '../pages/add_edit_account_page.dart';
import '../../../core/database/models/account.dart';

class EditAccountBottomSheet extends StatelessWidget {
  final Account account;
  const EditAccountBottomSheet({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return AddEditAccountPage(account: account);
  }
}
