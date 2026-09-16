import 'package:flutter/material.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_tabs.dart';
import '../widgets/notification_card.dart';
import '../widgets/search_and_filter_bar.dart';
import '../widgets/send_simulated_dialog.dart';
import '../widgets/stats_header.dart';

class HomeScreen extends StatelessWidget {
  final NotificationProvider provider;

  const HomeScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final filteredItems = provider.filteredNotifications;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryNeon.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryNeon, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notification Hub', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Real-time Categorized Stream', style: TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ],
        ),
        actions: [
          // Live API vs Offline Mock indicator button
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: provider.isLiveMode ? AppTheme.successGreen : AppTheme.primaryNeon,
            ),
            icon: Icon(
              provider.isLiveMode ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              size: 18,
            ),
            label: Text(
              provider.isLiveMode ? 'Live API' : 'Demo Mode',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () => provider.toggleLiveMode(),
          ),

          // Refresh Data Action
          IconButton(
            icon: provider.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => provider.loadData(),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNeon,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Simulate Push', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => SendSimulatedDialog.show(context, provider),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadData(),
        color: AppTheme.primaryNeon,
        backgroundColor: AppTheme.cardDark,
        child: CustomScrollView(
          slivers: [
            // Top Analytics Header
            SliverToBoxAdapter(
              child: StatsHeader(provider: provider),
            ),

            // Search & Filter Controls
            SliverToBoxAdapter(
              child: SearchAndFilterBar(provider: provider),
            ),

            // Horizontal Category Selector
            SliverToBoxAdapter(
              child: CategoryTabs(provider: provider),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Active Filters Summary Banner
            if (provider.selectedCategory != 'All' || provider.selectedAppPackage != null || provider.searchQuery.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Showing ${filteredItems.length} matching notification(s)',
                        style: const TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          provider.setSelectedCategory('All');
                          provider.setSelectedAppPackage(null);
                          provider.setSearchQuery('');
                          provider.setStatusFilter(StatusFilter.all);
                        },
                        child: const Text('Reset Filters', style: TextStyle(fontSize: 11, color: AppTheme.primaryNeon)),
                      ),
                    ],
                  ),
                ),
              ),

            // Main Notification List View
            if (filteredItems.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.white24),
                      SizedBox(height: 16),
                      Text(
                        'No notifications found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white60),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Try adjusting your search query or filters',
                        style: TextStyle(fontSize: 12, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.currentViewMode == ViewMode.groupedByApp)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final grouped = provider.groupedByAppNotifications;
                      final appName = grouped.keys.elementAt(index);
                      final items = grouped[appName]!;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorderDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppTheme.getPackageColor(items.first.packageName).withValues(alpha: 0.2),
                                  child: Icon(
                                    AppTheme.getPackageIcon(items.first.packageName),
                                    color: AppTheme.getPackageColor(items.first.packageName),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  appName,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryNeon.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${items.length}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNeon),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...items.map((item) => NotificationCard(
                                  item: item,
                                  provider: provider,
                                  isCompact: true,
                                )),
                          ],
                        ),
                      );
                    },
                    childCount: provider.groupedByAppNotifications.keys.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredItems[index];
                      return NotificationCard(
                        item: item,
                        provider: provider,
                        isCompact: provider.currentViewMode == ViewMode.compact,
                      );
                    },
                    childCount: filteredItems.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
