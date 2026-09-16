import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_item.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import 'payload_modal.dart';

class NotificationCard extends StatefulWidget {
  final NotificationItem item;
  final NotificationProvider provider;
  final bool isCompact;

  const NotificationCard({
    super.key,
    required this.item,
    required this.provider,
    this.isCompact = false,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final brandColor = AppTheme.getPackageColor(item.packageName);
    final brandIcon = AppTheme.getPackageIcon(item.packageName);
    final timeStr = _formatTime(item.receivedAt);

    if (widget.isCompact) {
      return _buildCompactCard(context, item, brandColor, brandIcon, timeStr);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: item.isPinned ? AppTheme.warningAmber : brandColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: App Avatar, Title/Subtext, Time, Pin Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Icon Badge
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: brandColor.withValues(alpha: 0.2),
                    child: Icon(brandIcon, color: brandColor, size: 20),
                  ),
                  const SizedBox(width: 12),

                  // App Name & Subtext
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.appDisplayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: brandColor,
                              ),
                            ),
                            if (item.subText != null && item.subText!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                '• ${item.subText}',
                                style: const TextStyle(fontSize: 12, color: Colors.white54),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            decoration: item.isRead ? TextDecoration.none : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Time Ago & Pin Toggle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeStr,
                        style: const TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.only(top: 4),
                        icon: Icon(
                          item.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                          size: 18,
                          color: item.isPinned ? AppTheme.warningAmber : Colors.white38,
                        ),
                        onPressed: () => widget.provider.togglePin(item.id),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Notification Main Text Body
              Text(
                item.text,
                style: const TextStyle(fontSize: 13, color: Color(0xDDFFFFFF), height: 1.4),
                maxLines: _isExpanded ? 100 : 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Expandable Big Text Container
              if (item.bigText != null && item.bigText!.isNotEmpty && _isExpanded) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.cardBorderDark),
                  ),
                  child: Text(
                    item.bigText!,
                    style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'monospace'),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Footer Pills: Category Tag, Duplicate Badge, Status Badge, Inspection Buttons
              Row(
                children: [
                  // Category Pill
                  _buildTag(
                    label: item.category.toUpperCase(),
                    color: AppTheme.primaryNeon.withValues(alpha: 0.2),
                    textColor: AppTheme.primaryNeon,
                  ),
                  const SizedBox(width: 6),

                  // Duplicate Warning Badge
                  if (item.isDuplicate)
                    _buildTag(
                      label: 'DUPLICATE',
                      color: AppTheme.warningAmber.withValues(alpha: 0.2),
                      textColor: AppTheme.warningAmber,
                      icon: Icons.copy_rounded,
                    ),

                  // Status Indicator Tag
                  _buildStatusTag(item.processingStatus),

                  const Spacer(),

                  // Expand BigText button (if available)
                  if (item.bigText != null && item.bigText!.isNotEmpty)
                    InkWell(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              _isExpanded ? 'Collapse' : 'Expand',
                              style: const TextStyle(fontSize: 11, color: AppTheme.primaryNeon, fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: AppTheme.primaryNeon,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(width: 8),

                  // Inspect Payload Modal Button
                  InkWell(
                    onTap: () => PayloadModal.show(context, item),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBorderDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.code_rounded, size: 14, color: Colors.white70),
                          SizedBox(width: 4),
                          Text('Payload', style: TextStyle(fontSize: 11, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, NotificationItem item, Color brandColor, IconData brandIcon, String timeStr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorderDark),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: brandColor.withValues(alpha: 0.2),
            child: Icon(brandIcon, color: brandColor, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.appDisplayName,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brandColor),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.text,
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.white38)),
          IconButton(
            icon: const Icon(Icons.code_rounded, size: 16, color: Colors.white60),
            onPressed: () => PayloadModal.show(context, item),
          ),
        ],
      ),
    );
  }

  Widget _buildTag({required String label, required Color color, required Color textColor, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(ProcessingStatusType status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case ProcessingStatusType.processed:
        bg = AppTheme.successGreen.withValues(alpha: 0.15);
        fg = AppTheme.successGreen;
        text = 'PROCESSED';
        break;
      case ProcessingStatusType.failed:
        bg = AppTheme.dangerRose.withValues(alpha: 0.15);
        fg = AppTheme.dangerRose;
        text = 'FAILED';
        break;
      case ProcessingStatusType.received:
        bg = AppTheme.infoBlue.withValues(alpha: 0.15);
        fg = AppTheme.infoBlue;
        text = 'RECEIVED';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: _buildTag(label: text, color: bg, textColor: fg),
    );
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d, HH:mm').format(dateTime);
  }
}
