class NotificationStats {
  final int totalNotifications;
  final int notificationsToday;
  final int notificationsThisWeek;
  final int duplicateCount;
  final int failedCount;
  final int processedCount;
  final Map<String, int> countByPackage;
  final Map<String, int> countByCategory;

  NotificationStats({
    required this.totalNotifications,
    required this.notificationsToday,
    required this.notificationsThisWeek,
    required this.duplicateCount,
    required this.failedCount,
    required this.processedCount,
    required this.countByPackage,
    required this.countByCategory,
  });

  factory NotificationStats.empty() {
    return NotificationStats(
      totalNotifications: 0,
      notificationsToday: 0,
      notificationsThisWeek: 0,
      duplicateCount: 0,
      failedCount: 0,
      processedCount: 0,
      countByPackage: {},
      countByCategory: {},
    );
  }
}
