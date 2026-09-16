import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';
import '../models/notification_stats.dart';
import '../services/notification_service.dart';

enum ViewMode {
  list,
  compact,
  groupedByApp,
}

enum StatusFilter {
  all,
  processed,
  received,
  failed,
  duplicates,
  pinned,
}

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationItem> _allNotifications = [];
  NotificationStats _stats = NotificationStats.empty();
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String? _selectedAppPackage;
  StatusFilter _selectedStatusFilter = StatusFilter.all;
  ViewMode _currentViewMode = ViewMode.list;
  bool _isLiveMode = true; // Live Mode by default
  String? _errorMessage;

  List<NotificationItem> get allNotifications => _allNotifications;
  NotificationStats get stats => _stats;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String? get selectedAppPackage => _selectedAppPackage;
  StatusFilter get selectedStatusFilter => _selectedStatusFilter;
  ViewMode get currentViewMode => _currentViewMode;
  bool get isLiveMode => _isLiveMode;
  String? get errorMessage => _errorMessage;

  NotificationProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _service.fetchNotifications(isLiveMode: _isLiveMode);
      // Retain any live pushed notifications in local state
      final Map<String, NotificationItem> itemMap = {};
      for (var item in fetched) {
        itemMap[item.id] = item;
      }
      for (var item in _allNotifications) {
        if (!itemMap.containsKey(item.id) && _isLiveMode) {
          itemMap[item.id] = item;
        }
      }
      _allNotifications = itemMap.values.toList();
      _stats = await _service.fetchStats(isLiveMode: _isLiveMode);
    } catch (e) {
      _errorMessage = 'Error loading notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedAppPackage(String? pkg) {
    _selectedAppPackage = _selectedAppPackage == pkg ? null : pkg;
    notifyListeners();
  }

  void setStatusFilter(StatusFilter filter) {
    _selectedStatusFilter = filter;
    notifyListeners();
  }

  void setViewMode(ViewMode mode) {
    _currentViewMode = mode;
    notifyListeners();
  }

  void toggleLiveMode() {
    _isLiveMode = !_isLiveMode;
    _allNotifications.clear();
    loadData();
  }

  void togglePin(String id) {
    final index = _allNotifications.indexWhere((item) => item.id == id);
    if (index != -1) {
      _allNotifications[index].isPinned = !_allNotifications[index].isPinned;
      notifyListeners();
    }
  }

  void toggleRead(String id) {
    final index = _allNotifications.indexWhere((item) => item.id == id);
    if (index != -1) {
      _allNotifications[index].isRead = !_allNotifications[index].isRead;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var item in _allNotifications) {
      item.isRead = true;
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _allNotifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<bool> addSimulatedNotification(NotificationItem newItem) async {
    _allNotifications.insert(0, newItem);
    notifyListeners();
    return await _service.sendSimulatedNotification(newItem);
  }

  // Filtered Notifications getter
  List<NotificationItem> get filteredNotifications {
    return _allNotifications.where((item) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(q);
        final matchesText = item.text.toLowerCase().contains(q);
        final matchesPkg = item.packageName.toLowerCase().contains(q);
        final matchesSub = item.subText?.toLowerCase().contains(q) ?? false;
        final matchesBig = item.bigText?.toLowerCase().contains(q) ?? false;
        final matchesHash = item.deduplicationHash.toLowerCase().contains(q);

        if (!matchesTitle && !matchesText && !matchesPkg && !matchesSub && !matchesBig && !matchesHash) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != 'All') {
        if (_selectedCategory == 'Messages' && item.categoryType != NotificationCategoryType.messages) return false;
        if (_selectedCategory == 'Finance' && item.categoryType != NotificationCategoryType.finance) return false;
        if (_selectedCategory == 'System' && item.categoryType != NotificationCategoryType.system) return false;
        if (_selectedCategory == 'Security' && item.categoryType != NotificationCategoryType.security) return false;
        if (_selectedCategory == 'Social' && item.categoryType != NotificationCategoryType.social) return false;
        if (_selectedCategory == 'Promos' && item.categoryType != NotificationCategoryType.promotional) return false;
      }

      // App Package filter
      if (_selectedAppPackage != null && _selectedAppPackage!.isNotEmpty) {
        if (item.appDisplayName != _selectedAppPackage && item.packageName != _selectedAppPackage) {
          return false;
        }
      }

      // Status filter
      switch (_selectedStatusFilter) {
        case StatusFilter.processed:
          if (item.processingStatus != ProcessingStatusType.processed) return false;
          break;
        case StatusFilter.received:
          if (item.processingStatus != ProcessingStatusType.received) return false;
          break;
        case StatusFilter.failed:
          if (item.processingStatus != ProcessingStatusType.failed) return false;
          break;
        case StatusFilter.duplicates:
          if (!item.isDuplicate) return false;
          break;
        case StatusFilter.pinned:
          if (!item.isPinned) return false;
          break;
        case StatusFilter.all:
          break;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Pinned first, then by date descending
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.receivedAt.compareTo(a.receivedAt);
      });
  }

  Map<String, List<NotificationItem>> get groupedByAppNotifications {
    final Map<String, List<NotificationItem>> grouped = {};
    for (var item in filteredNotifications) {
      final appName = item.appDisplayName;
      grouped.putIfAbsent(appName, () => []).add(item);
    }
    return grouped;
  }

  List<String> get availableAppNames {
    final Set<String> names = {};
    for (var item in _allNotifications) {
      names.add(item.appDisplayName);
    }
    return names.toList()..sort();
  }
}
