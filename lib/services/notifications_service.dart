import 'package:flutter/foundation.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final String? imageAsset;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.imageAsset,
    this.read = false,
  });
}

class NotificationsService extends ChangeNotifier {
  NotificationsService._() {
    // seed sample data; will be replaced by Firebase later
    final now = DateTime.now();
    _items.addAll([
      AppNotification(
        id: 'n1',
        title: 'مرحبًا بك في Rtouch',
        body: 'تسوق أحدث الإكسسوارات الذكية بأفضل الأسعار وتوصيل سريع.',
        time: now.subtract(const Duration(minutes: 5)),
      ),
      AppNotification(
        id: 'n2',
        title: 'عرض خاص على باور بانك RP-130',
        body: 'خصم محدود على الباور بانك 130W. اطلب الآن قبل نفاد الكمية.',
        time: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'n3',
        title: 'وصل حديثًا • سماعات RB-500HB',
        body: 'تشغيل 25 ساعة وبلوتوث 6.0 — جودة فاخرة بسعر منافس.',
        time: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ]);
  }
  static final NotificationsService instance = NotificationsService._();

  final List<AppNotification> _items = [];
  List<AppNotification> get items =>
      List.unmodifiable(_items..sort((a, b) => b.time.compareTo(a.time)));
  int get unreadCount => _items.where((e) => !e.read).length;

  void markAllRead() {
    for (final n in _items) {
      n.read = true;
    }
    notifyListeners();
  }

  void markRead(String id) {
    final n = _items.firstWhere((e) => e.id == id, orElse: () => _items.first);
    n.read = true;
    notifyListeners();
  }

  void addRemote({required String title, required String body}) {
    _items.insert(
      0,
      AppNotification(
        id: 'fcm-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        time: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
