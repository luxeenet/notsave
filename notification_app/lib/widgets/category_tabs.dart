import 'package:flutter/material.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';

class CategoryTabs extends StatelessWidget {
  final NotificationProvider provider;

  const CategoryTabs({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'All', 'icon': Icons.all_inclusive_rounded},
      {'name': 'Messages', 'icon': Icons.chat_bubble_outline_rounded},
      {'name': 'Finance', 'icon': Icons.account_balance_wallet_outlined},
      {'name': 'System', 'icon': Icons.tune_rounded},
      {'name': 'Security', 'icon': Icons.shield_outlined},
      {'name': 'Social', 'icon': Icons.people_outline_rounded},
      {'name': 'Promos', 'icon': Icons.local_offer_outlined},
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final name = cat['name'] as String;
          final icon = cat['icon'] as IconData;
          final isSelected = provider.selectedCategory == name;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              avatar: Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.white60,
              ),
              label: Text(name),
              selectedColor: AppTheme.primaryNeon,
              backgroundColor: AppTheme.cardDark,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryNeon : AppTheme.cardBorderDark,
                width: 1,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              onSelected: (_) {
                provider.setSelectedCategory(name);
              },
            ),
          );
        },
      ),
    );
  }
}
