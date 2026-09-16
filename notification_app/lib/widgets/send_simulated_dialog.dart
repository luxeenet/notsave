import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';

class SendSimulatedDialog extends StatefulWidget {
  final NotificationProvider provider;

  const SendSimulatedDialog({super.key, required this.provider});

  static void show(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => SendSimulatedDialog(provider: provider),
    );
  }

  @override
  State<SendSimulatedDialog> createState() => _SendSimulatedDialogState();
}

class _SendSimulatedDialogState extends State<SendSimulatedDialog> {
  final _titleController = TextEditingController(text: 'Security Alert: New Login');
  final _textController = TextEditingController(text: 'New sign-in detected on Pixel 8 Pro from San Francisco, CA');
  final _subTextController = TextEditingController(text: 'Google Account');
  final _bigTextController = TextEditingController(text: 'If this was you, no action is required. If not, secure your account immediately.');
  String _selectedPackage = 'com.google.android.gm';
  final String _selectedCategory = 'security';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.cardBorderDark),
      ),
      title: const Row(
        children: [
          Icon(Icons.add_alert_rounded, color: AppTheme.primaryNeon),
          SizedBox(width: 10),
          Text('Simulate Android Push', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Dropdown
              const Text('App Package Name', style: TextStyle(fontSize: 12, color: Colors.white60)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: _selectedPackage,
                dropdownColor: AppTheme.cardDark,
                items: const [
                  DropdownMenuItem(value: 'com.whatsapp', child: Text('com.whatsapp (WhatsApp)')),
                  DropdownMenuItem(value: 'com.google.android.gm', child: Text('com.google.android.gm (Gmail)')),
                  DropdownMenuItem(value: 'com.slack', child: Text('com.slack (Slack)')),
                  DropdownMenuItem(value: 'com.chase.sig.android', child: Text('com.chase.sig.android (Chase)')),
                  DropdownMenuItem(value: 'com.android.systemui', child: Text('com.android.systemui (System)')),
                ],
                onChanged: (val) => setState(() => _selectedPackage = val!),
              ),
              const SizedBox(height: 12),

              // Title Field
              const Text('Title', style: TextStyle(fontSize: 12, color: Colors.white60)),
              const SizedBox(height: 4),
              TextField(controller: _titleController),
              const SizedBox(height: 12),

              // Text Field
              const Text('Notification Text Body', style: TextStyle(fontSize: 12, color: Colors.white60)),
              const SizedBox(height: 4),
              TextField(controller: _textController, maxLines: 2),
              const SizedBox(height: 12),

              // SubText Field
              const Text('SubText (Optional)', style: TextStyle(fontSize: 12, color: Colors.white60)),
              const SizedBox(height: 4),
              TextField(controller: _subTextController),
              const SizedBox(height: 12),

              // BigText Field
              const Text('BigText / Expanded (Optional)', style: TextStyle(fontSize: 12, color: Colors.white60)),
              const SizedBox(height: 4),
              TextField(controller: _bigTextController, maxLines: 2),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryNeon,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text('Push Notification'),
          onPressed: () {
            final now = DateTime.now();
            final newItem = NotificationItem(
              id: 'sim_${now.millisecondsSinceEpoch}',
              notificationId: 'nid_${now.millisecondsSinceEpoch}',
              deduplicationHash: 'hash_${now.millisecondsSinceEpoch.toRadixString(16)}',
              packageName: _selectedPackage,
              title: _titleController.text,
              text: _textController.text,
              subText: _subTextController.text.isNotEmpty ? _subTextController.text : null,
              bigText: _bigTextController.text.isNotEmpty ? _bigTextController.text : null,
              category: _selectedCategory,
              deviceTimestamp: now,
              receivedAt: now,
              firstReceivedAt: now,
              lastReceivedAt: now,
              rawPayload: {
                'packageName': _selectedPackage,
                'title': _titleController.text,
                'text': _textController.text,
                'simulated': true,
                'timestamp': now.millisecondsSinceEpoch,
              },
              requestId: 'req_sim_${now.millisecondsSinceEpoch}',
              source: 'Simulated Device Push',
              processingStatus: ProcessingStatusType.processed,
              deliveryAttempts: 1,
            );

            widget.provider.addSimulatedNotification(newItem);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Simulated notification dispatched successfully!'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
          },
        ),
      ],
    );
  }
}
