import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class PlayStoreUpdateChecker {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // Show custom dialog to the user
        bool userAccepted =
            await showDialog<bool>(
              // ignore: use_build_context_synchronously
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Update Available'),
                content: const Text(
                  'A new version of this app is available. Please update to continue using the latest features.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Later'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Update'),
                  ),
                ],
              ),
            ) ??
            false;

        if (userAccepted) {
          // Perform immediate update
          await InAppUpdate.performImmediateUpdate();

          // OR if you prefer flexible update
          // await InAppUpdate.startFlexibleUpdate();
        }
      } else {
        debugPrint('No update available');
      }
    } catch (e) {
      debugPrint("Error checking for Play Store update: $e");
    }
  }

  static Future<void> showMockUpdateDialog(BuildContext context) async {
    final userAccepted =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Update Available'),
            content: const Text(
              'A new version of this app is available. Please update to continue using the latest features.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Update'),
              ),
            ],
          ),
        ) ??
        false;

    if (userAccepted) {
      // Here you can simulate the update
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Simulating update...')));
    }
  }
}

// Future<void> showMockUpdateDialog(BuildContext context) async {
//   final userAccepted =
//       await showDialog<bool>(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Text('Update Available'),
//           content: const Text(
//             'A new version of this app is available. Please update to continue using the latest features.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Later'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Update'),
//             ),
//           ],
//         ),
//       ) ??
//       false;

//   if (userAccepted) {
//     // Here you can simulate the update
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Simulating update...')));
//   }
// }
