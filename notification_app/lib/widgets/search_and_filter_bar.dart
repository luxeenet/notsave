import 'package:flutter/material.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';

class SearchAndFilterBar extends StatelessWidget {
  final NotificationProvider provider;

  const SearchAndFilterBar({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search Input Field
          TextField(
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search by Title, Package, Text, or Hash...',
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white60),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white60),
                      onPressed: () => provider.setSearchQuery(''),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),

          // Status & View Mode Controls Bar
          Row(
            children: [
              // Status Filter Dropdown / Menu Button
              PopupMenuButton<StatusFilter>(
                initialValue: provider.selectedStatusFilter,
                onSelected: provider.setStatusFilter,
                color: AppTheme.cardDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.cardBorderDark),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.cardBorderDark),
                  ),
                  child: Row(
                    children: [
                      Icon(_getStatusIcon(provider.selectedStatusFilter), size: 16, color: AppTheme.primaryNeon),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusLabel(provider.selectedStatusFilter),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down_rounded, color: Colors.white60, size: 18),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  _buildMenuItem(StatusFilter.all, 'All Statuses', Icons.border_all_rounded),
                  _buildMenuItem(StatusFilter.processed, 'Processed', Icons.check_circle_outline_rounded),
                  _buildMenuItem(StatusFilter.received, 'Received', Icons.inbox_rounded),
                  _buildMenuItem(StatusFilter.failed, 'Failed', Icons.error_outline_rounded),
                  _buildMenuItem(StatusFilter.duplicates, 'Duplicates', Icons.copy_rounded),
                  _buildMenuItem(StatusFilter.pinned, 'Pinned Items', Icons.push_pin_rounded),
                ],
              ),
              const SizedBox(width: 8),

              // Filter by Specific App Package Popup
              if (provider.availableAppNames.isNotEmpty)
                PopupMenuButton<String?>(
                  initialValue: provider.selectedAppPackage,
                  onSelected: provider.setSelectedAppPackage,
                  color: AppTheme.cardDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.cardBorderDark),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: provider.selectedAppPackage != null ? AppTheme.primaryAccent.withValues(alpha: 0.2) : AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: provider.selectedAppPackage != null ? AppTheme.primaryAccent : AppTheme.cardBorderDark,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.apps_rounded,
                          size: 16,
                          color: provider.selectedAppPackage != null ? AppTheme.primaryAccent : Colors.white60,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.selectedAppPackage ?? 'All Apps',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: provider.selectedAppPackage != null ? AppTheme.primaryAccent : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem<String?>(
                      value: null,
                      child: Text('All App Packages'),
                    ),
                    ...provider.availableAppNames.map((app) => PopupMenuItem<String?>(
                          value: app,
                          child: Row(
                            children: [
                              Icon(AppTheme.getPackageIcon(app), size: 16, color: AppTheme.getPackageColor(app)),
                              const SizedBox(width: 8),
                              Text(app),
                            ],
                          ),
                        )),
                  ],
                ),

              const Spacer(),

              // View Mode Toggle Switches
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.cardBorderDark),
                ),
                child: Row(
                  children: [
                    _buildViewIconButton(ViewMode.list, Icons.view_list_rounded),
                    _buildViewIconButton(ViewMode.compact, Icons.view_headline_rounded),
                    _buildViewIconButton(ViewMode.groupedByApp, Icons.grid_view_rounded),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<StatusFilter> _buildMenuItem(StatusFilter filter, String title, IconData icon) {
    return PopupMenuItem<StatusFilter>(
      value: filter,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildViewIconButton(ViewMode mode, IconData icon) {
    final isSelected = provider.currentViewMode == mode;
    return InkWell(
      onTap: () => provider.setViewMode(mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNeon : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : Colors.white60,
        ),
      ),
    );
  }

  IconData _getStatusIcon(StatusFilter filter) {
    switch (filter) {
      case StatusFilter.processed:
        return Icons.check_circle_outline_rounded;
      case StatusFilter.received:
        return Icons.inbox_rounded;
      case StatusFilter.failed:
        return Icons.error_outline_rounded;
      case StatusFilter.duplicates:
        return Icons.copy_rounded;
      case StatusFilter.pinned:
        return Icons.push_pin_rounded;
      case StatusFilter.all:
        return Icons.filter_alt_rounded;
    }
  }

  String _getStatusLabel(StatusFilter filter) {
    switch (filter) {
      case StatusFilter.processed:
        return 'Processed';
      case StatusFilter.received:
        return 'Received';
      case StatusFilter.failed:
        return 'Failed';
      case StatusFilter.duplicates:
        return 'Duplicates';
      case StatusFilter.pinned:
        return 'Pinned';
      case StatusFilter.all:
        return 'Filter Status';
    }
  }
}
