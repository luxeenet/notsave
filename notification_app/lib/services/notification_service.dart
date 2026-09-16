import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_item.dart';
import '../models/notification_stats.dart';
import 'mock_data.dart';

class NotificationService {
  final String baseUrl;
  final String authToken;

  NotificationService({
    this.baseUrl = 'https://notsave.pamtok.com/api/v1',
    this.authToken = '7f3a9c2e8b1d4a6f5e9c3b7d2a8f1e6c4d9b0a7f3e2c8d6b1a5f9e4c7d2b8a6',
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
      };

  Future<List<NotificationItem>> fetchNotifications({
    int page = 1,
    int limit = 50,
    String? category,
    String? packageName,
    String? search,
    bool isLiveMode = true,
  }) async {
    if (!isLiveMode) {
      // In explicit Demo Mode, return sample mock notifications dataset
      List<NotificationItem> items = MockDataGenerator.generateMockNotifications();
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        items = items.where((item) =>
          item.title.toLowerCase().contains(q) ||
          item.text.toLowerCase().contains(q) ||
          item.packageName.toLowerCase().contains(q) ||
          (item.bigText?.toLowerCase().contains(q) ?? false) ||
          item.deduplicationHash.toLowerCase().contains(q)
        ).toList();
      }
      return items;
    }

    // In Live Mode, query the real remote production server
    try {
      final uri = Uri.parse('$baseUrl/notifications').replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (category != null && category.isNotEmpty && category != 'All') 'category': category,
        if (packageName != null && packageName.isNotEmpty) 'packageName': packageName,
        if (search != null && search.isNotEmpty) 'search': search,
      });

      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List? rawItems;
        if (data['data'] != null && data['data']['items'] is List) {
          rawItems = data['data']['items'];
        } else if (data['items'] is List) {
          rawItems = data['items'];
        } else if (data is List) {
          rawItems = data;
        }

        if (rawItems != null) {
          return rawItems.map((item) => NotificationItem.fromJson(item)).toList();
        }
      }
    } catch (_) {
      // Network error or 404 endpoint
    }

    // Return empty list in Live Mode when no server GET notifications are returned yet
    return [];
  }

  Future<NotificationStats> fetchStats({bool isLiveMode = true}) async {
    if (!isLiveMode) {
      final mockItems = MockDataGenerator.generateMockNotifications();
      final now = DateTime.now();
      final todayCount = mockItems.where((i) => i.receivedAt.day == now.day && i.receivedAt.month == now.month).length;
      final duplicates = mockItems.where((i) => i.isDuplicate).length;
      final failed = mockItems.where((i) => i.processingStatus == ProcessingStatusType.failed).length;
      final processed = mockItems.where((i) => i.processingStatus == ProcessingStatusType.processed).length;

      final Map<String, int> pkgMap = {};
      final Map<String, int> catMap = {};

      for (var item in mockItems) {
        pkgMap[item.appDisplayName] = (pkgMap[item.appDisplayName] ?? 0) + 1;
        catMap[item.category] = (catMap[item.category] ?? 0) + 1;
      }

      return NotificationStats(
        totalNotifications: mockItems.length,
        notificationsToday: todayCount,
        notificationsThisWeek: mockItems.length,
        duplicateCount: duplicates,
        failedCount: failed,
        processedCount: processed,
        countByPackage: pkgMap,
        countByCategory: catMap,
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/notifications/stats');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] != null) {
          final d = json['data'];
          final Map<String, int> pkgMap = {};
          if (d['notificationsByPackage'] is List) {
            for (var item in d['notificationsByPackage']) {
              pkgMap[item['_id']?.toString() ?? 'unknown'] = (item['count'] as num).toInt();
            }
          }
          final Map<String, int> catMap = {};
          if (d['notificationsByCategory'] is List) {
            for (var item in d['notificationsByCategory']) {
              catMap[item['_id']?.toString() ?? 'unknown'] = (item['count'] as num).toInt();
            }
          }

          return NotificationStats(
            totalNotifications: (d['totalNotifications'] as num?)?.toInt() ?? 0,
            notificationsToday: (d['notificationsToday'] as num?)?.toInt() ?? 0,
            notificationsThisWeek: (d['notificationsThisWeek'] as num?)?.toInt() ?? 0,
            duplicateCount: (d['duplicateDeliveryCount'] as num?)?.toInt() ?? 0,
            failedCount: (d['failedProcessingCount'] as num?)?.toInt() ?? 0,
            processedCount: (d['totalNotifications'] as num?)?.toInt() ?? 0,
            countByPackage: pkgMap,
            countByCategory: catMap,
          );
        }
      }
    } catch (_) {
      // Ignore network errors
    }

    return NotificationStats.empty();
  }

  Future<bool> sendSimulatedNotification(NotificationItem item) async {
    try {
      final uri = Uri.parse('$baseUrl/notifications');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'packageName': item.packageName,
          'title': item.title,
          'text': item.text,
          'subText': item.subText,
          'bigText': item.bigText,
          'category': item.category,
          'time': item.deviceTimestamp.millisecondsSinceEpoch,
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
