import 'package:flutter/material.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';

class StatsHeader extends StatelessWidget {
  final NotificationProvider provider;

  const StatsHeader({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final stats = provider.stats;

    return Column(
      children: [
        // Stat Cards Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildStatCard(
                title: 'Total Received',
                value: stats.totalNotifications.toString(),
                icon: Icons.notifications_rounded,
                color: AppTheme.primaryNeon,
                subtext: '${stats.notificationsToday} Today',
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Processed',
                value: stats.processedCount.toString(),
                icon: Icons.check_circle_rounded,
                color: AppTheme.successGreen,
                subtext: 'Healthy Stream',
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Duplicates',
                value: stats.duplicateCount.toString(),
                icon: Icons.copy_rounded,
                color: AppTheme.warningAmber,
                subtext: 'Filtered',
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Processing Failures',
                value: stats.failedCount.toString(),
                icon: Icons.error_outline_rounded,
                color: AppTheme.dangerRose,
                subtext: 'Attention Needed',
              ),
            ],
          ),
        ),

        // App Distribution Progress Bar
        if (provider.availableAppNames.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'App Package Distribution',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                      Text(
                        '${provider.availableAppNames.length} Active Apps',
                        style: const TextStyle(fontSize: 11, color: AppTheme.primaryNeon),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: provider.availableAppNames.map((appName) {
                          final count = provider.stats.countByPackage[appName] ?? 1;
                          final total = provider.allNotifications.isEmpty ? 1 : provider.allNotifications.length;
                          final flex = (count / total * 100).clamp(1, 100).toInt();

                          return Expanded(
                            flex: flex,
                            child: Container(
                              color: AppTheme.getPackageColor(appName),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtext,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorderDark),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w500),
          ),
          Text(
            subtext,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
