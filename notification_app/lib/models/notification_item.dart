import 'dart:convert';
import 'package:flutter/material.dart';

enum NotificationCategoryType {
  messages,
  finance,
  system,
  security,
  social,
  promotional,
  custom,
}

enum ProcessingStatusType {
  received,
  processed,
  failed,
}

class NotificationItem {
  final String id;
  final String notificationId;
  final String deduplicationHash;
  final String packageName;
  final String? key;
  final String title;
  final String text;
  final String? subText;
  final String? bigText;
  final String category;
  final DateTime deviceTimestamp;
  final DateTime receivedAt;
  final DateTime firstReceivedAt;
  final DateTime lastReceivedAt;
  final Map<String, dynamic> rawPayload;
  final String requestId;
  final String source;
  final ProcessingStatusType processingStatus;
  final int deliveryAttempts;
  final String? ipHash;
  final String? userAgent;
  final bool isDuplicate;
  bool isPinned;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.notificationId,
    required this.deduplicationHash,
    required this.packageName,
    this.key,
    required this.title,
    required this.text,
    this.subText,
    this.bigText,
    required this.category,
    required this.deviceTimestamp,
    required this.receivedAt,
    required this.firstReceivedAt,
    required this.lastReceivedAt,
    required this.rawPayload,
    required this.requestId,
    required this.source,
    required this.processingStatus,
    required this.deliveryAttempts,
    this.ipHash,
    this.userAgent,
    this.isDuplicate = false,
    this.isPinned = false,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    ProcessingStatusType parseStatus(String? statusStr) {
      switch (statusStr?.toLowerCase()) {
        case 'processed':
          return ProcessingStatusType.processed;
        case 'failed':
          return ProcessingStatusType.failed;
        case 'received':
        default:
          return ProcessingStatusType.received;
      }
    }

    DateTime parseDate(dynamic dateVal) {
      if (dateVal == null) return DateTime.now();
      if (dateVal is num) return DateTime.fromMillisecondsSinceEpoch(dateVal.toInt());
      return DateTime.tryParse(dateVal.toString()) ?? DateTime.now();
    }

    return NotificationItem(
      id: json['_id']?.toString() ?? json['notificationId']?.toString() ?? UniqueKey().toString(),
      notificationId: json['notificationId']?.toString() ?? 'N/A',
      deduplicationHash: json['deduplicationHash']?.toString() ?? '',
      packageName: json['packageName']?.toString() ?? 'com.system.app',
      key: json['key']?.toString(),
      title: json['title']?.toString() ?? 'No Title',
      text: json['text']?.toString() ?? 'No Text Content',
      subText: json['subText']?.toString(),
      bigText: json['bigText']?.toString(),
      category: json['category']?.toString() ?? 'uncategorized',
      deviceTimestamp: parseDate(json['deviceTimestamp'] ?? json['time']),
      receivedAt: parseDate(json['receivedAt']),
      firstReceivedAt: parseDate(json['firstReceivedAt'] ?? json['receivedAt']),
      lastReceivedAt: parseDate(json['lastReceivedAt'] ?? json['receivedAt']),
      rawPayload: json['rawPayload'] is Map<String, dynamic>
          ? json['rawPayload']
          : (json['rawPayload'] is String
              ? (tryParseJson(json['rawPayload']) ?? {'raw': json['rawPayload']})
              : json),
      requestId: json['requestId']?.toString() ?? 'req_unknown',
      source: json['source']?.toString() ?? 'Android Service',
      processingStatus: parseStatus(json['processingStatus']),
      deliveryAttempts: (json['deliveryAttempts'] as num?)?.toInt() ?? 1,
      ipHash: json['ipHash']?.toString(),
      userAgent: json['userAgent']?.toString(),
      isDuplicate: json['duplicate'] == true,
      isPinned: json['isPinned'] == true,
      isRead: json['isRead'] == true,
    );
  }

  static Map<String, dynamic>? tryParseJson(String source) {
    try {
      return jsonDecode(source) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  NotificationCategoryType get categoryType {
    final cat = category.toLowerCase();
    final pkg = packageName.toLowerCase();

    if (cat.contains('msg') || cat.contains('message') || pkg.contains('whatsapp') || pkg.contains('telegram') || pkg.contains('slack') || pkg.contains('signal')) {
      return NotificationCategoryType.messages;
    }
    if (cat.contains('finance') || cat.contains('payment') || cat.contains('bank') || pkg.contains('bank') || pkg.contains('paypal') || pkg.contains('stripe') || pkg.contains('wallet')) {
      return NotificationCategoryType.finance;
    }
    if (cat.contains('sys') || cat.contains('status') || cat.contains('service') || pkg.contains('android') || pkg.contains('system')) {
      return NotificationCategoryType.system;
    }
    if (cat.contains('sec') || cat.contains('alert') || cat.contains('warn') || cat.contains('auth')) {
      return NotificationCategoryType.security;
    }
    if (cat.contains('social') || pkg.contains('twitter') || pkg.contains('instagram') || pkg.contains('facebook') || pkg.contains('linkedin')) {
      return NotificationCategoryType.social;
    }
    if (cat.contains('promo') || cat.contains('offer') || cat.contains('event')) {
      return NotificationCategoryType.promotional;
    }
    return NotificationCategoryType.custom;
  }

  String get appDisplayName {
    if (packageName.contains('whatsapp')) return 'WhatsApp';
    if (packageName.contains('telegram')) return 'Telegram';
    if (packageName.contains('slack')) return 'Slack';
    if (packageName.contains('gm') || packageName.contains('gmail')) return 'Gmail';
    if (packageName.contains('bank') || packageName.contains('chase')) return 'Chase Bank';
    if (packageName.contains('stripe')) return 'Stripe Payment';
    if (packageName.contains('github')) return 'GitHub';
    if (packageName.contains('uber')) return 'Uber Eats';
    if (packageName.contains('system') || packageName.contains('android')) return 'Android System';
    if (packageName.contains('twitter') || packageName.contains('x.app')) return 'X / Twitter';
    if (packageName.contains('instagram')) return 'Instagram';

    final parts = packageName.split('.');
    if (parts.length >= 2) {
      return parts.last[0].toUpperCase() + parts.last.substring(1);
    }
    return packageName;
  }

  String get prettyRawJson {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(rawPayload);
  }
}
