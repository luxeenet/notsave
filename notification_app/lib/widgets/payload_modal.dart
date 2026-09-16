import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/notification_item.dart';
import '../theme/app_theme.dart';

class PayloadModal extends StatelessWidget {
  final NotificationItem item;

  const PayloadModal({super.key, required this.item});

  static void show(BuildContext context, NotificationItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PayloadModal(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.cardBorderDark, width: 1.5)),
      ),
      child: Column(
        children: [
          // Drag handle pill
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Modal Title Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.getPackageColor(item.packageName).withValues(alpha: 0.2),
                  child: Icon(
                    AppTheme.getPackageIcon(item.packageName),
                    color: AppTheme.getPackageColor(item.packageName),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.appDisplayName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Notification ID: ${item.notificationId}',
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.cardBorderDark, height: 1),

          // Body Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Quick Info Metadata Cards Grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildMetaCard('Request ID', item.requestId, Icons.fingerprint_rounded),
                    _buildMetaCard('Deduplication Hash', item.deduplicationHash, Icons.tag_rounded),
                    _buildMetaCard('Device Time', dateFormat.format(item.deviceTimestamp), Icons.schedule_rounded),
                    _buildMetaCard('First Received', dateFormat.format(item.firstReceivedAt), Icons.access_time_filled_rounded),
                    _buildMetaCard('Delivery Attempts', '${item.deliveryAttempts} attempt(s)', Icons.numbers_rounded),
                    _buildMetaCard('IP Hash', item.ipHash ?? 'N/A', Icons.network_ping_rounded),
                    _buildMetaCard('User Agent', item.userAgent ?? 'System Gateway', Icons.devices_rounded),
                    _buildMetaCard('Category', item.category, Icons.category_rounded),
                  ],
                ),
                const SizedBox(height: 24),

                // JSON Payload Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Raw JSON Payload',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cardDark,
                        foregroundColor: AppTheme.primaryNeon,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppTheme.cardBorderDark),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy JSON', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: item.prettyRawJson));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Raw JSON payload copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Formatted JSON Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.cardBorderDark),
                  ),
                  child: SelectableText(
                    item.prettyRawJson,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Color(0xFF38BDF8), // Light Cyan code color
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(String title, String value, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.primaryNeon),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
