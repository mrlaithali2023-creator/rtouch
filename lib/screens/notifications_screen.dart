import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../services/notifications_service.dart';
import '../theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationsService.instance.markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          IconButton(
            tooltip: 'تعليم الكل كمقروء',
            onPressed: () => NotificationsService.instance.markAllRead(),
            icon: const Icon(Icons.done_all_rounded),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: NotificationsService.instance,
        builder: (_, _) {
          final items = NotificationsService.instance.items;
          if (items.isEmpty) {
            return _empty();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = items[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEFE7D6)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.campaign_rounded,
                          color: AppColors.goldDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(n.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                    )),
                              ),
                              Text(_formatTime(n.time),
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(n.body,
                              style: const TextStyle(
                                  color: AppColors.inkSoft, height: 1.6)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes}د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours}س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays}ي';
    return intl.DateFormat('yyyy/MM/dd').format(t);
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                size: 56, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          const Text('لا توجد إشعارات بعد',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('سنعلمك بكل العروض والمنتجات الجديدة',
              style: TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}
