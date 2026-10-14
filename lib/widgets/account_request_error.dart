import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../screens/login_screen.dart';

/// Expiry never silently replays a POST or DELETE under a different account.
class AccountRequestError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const AccountRequestError({
    super.key,
    required this.error,
    required this.onRetry,
  });
  @override
  Widget build(BuildContext context) {
    final expired =
        error is ApiException && (error as ApiException).statusCode == 401;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error.toString(), textAlign: TextAlign.center),
            TextButton(
              onPressed: () async {
                if (!expired) {
                  onRetry();
                  return;
                }
                final success = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                if (success == true && context.mounted) onRetry();
              },
              child: Text(expired ? '重新登入' : '重新載入'),
            ),
          ],
        ),
      ),
    );
  }
}
