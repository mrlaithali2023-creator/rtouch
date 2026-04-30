import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/cart_service.dart';
import '../theme.dart';

/// Yemeni payment options shown to the user.
/// When tapped, the app tries to open the related wallet via:
/// 1. Android intent / package launch (where supported)
/// 2. Custom URL scheme
/// 3. Falls back to a friendly dialog instructing the user to open it manually.
class PaymentOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  /// Optional Android package name to launch.
  final String? androidPackage;

  /// Optional custom URL scheme to attempt.
  final String? scheme;

  const PaymentOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.androidPackage,
    this.scheme,
  });
}

const _walletOptions = <PaymentOption>[
  PaymentOption(
    id: 'cash',
    title: 'الدفع نقدًا عند الاستلام',
    subtitle: 'ادفع كاش عند وصول الطلب',
    icon: Icons.payments_outlined,
    color: Color(0xFF1FAE6A),
  ),
  PaymentOption(
    id: 'floosak',
    title: 'محفظة فلوسك',
    subtitle: 'CAC Bank • Floosak',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFF1565C0),
    androidPackage: 'com.cac.floosak',
    scheme: 'floosak://',
  ),
  PaymentOption(
    id: 'jaib',
    title: 'محفظة جيب',
    subtitle: 'بنك الكريمي • Jaib',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFF1B7C5A),
    androidPackage: 'com.kuraimi.jaib',
    scheme: 'jaib://',
  ),
  PaymentOption(
    id: 'jawali',
    title: 'محفظة جوالي',
    subtitle: 'سبأفون • Jawali',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFFD12C2C),
    androidPackage: 'com.sabafon.jawali',
    scheme: 'jawali://',
  ),
  PaymentOption(
    id: 'mfloos',
    title: 'محفظة Mfloos',
    subtitle: 'بنك اليمن والكويت',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFF6A1B9A),
    androidPackage: 'com.ykb.mfloos',
    scheme: 'mfloos://',
  ),
  PaymentOption(
    id: 'onecash',
    title: 'محفظة ONECash',
    subtitle: 'بنك التضامن • ONECash',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFFEF6C00),
    androidPackage: 'com.tib.onecash',
    scheme: 'onecash://',
  ),
  PaymentOption(
    id: 'cash_wallet',
    title: 'محفظة كاش',
    subtitle: 'Cash Wallet',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFF00897B),
    androidPackage: 'com.cash.wallet',
    scheme: 'cashwallet://',
  ),
];

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  final _walletReceipt = TextEditingController();

  PaymentOption? _selected;
  late final String _orderId;

  // Rtouch WhatsApp business number (international format, no +).
  static const String kWhatsappNumber = '967770233330';

  @override
  void initState() {
    super.initState();
    final r = Random().nextInt(900000) + 100000;
    final ts = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    _orderId = 'RT-$ts-$r';
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _address.dispose();
    _notes.dispose();
    _walletReceipt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: AnimatedBuilder(
        animation: cart,
        builder: (_, __) {
          if (cart.isEmpty) {
            return const Center(child: Text('سلتك فارغة'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle('بيانات التوصيل'),
                  const SizedBox(height: 8),
                  _field(_name, 'الاسم الكامل',
                      Icons.person_outline_rounded, validator: _required),
                  const SizedBox(height: 10),
                  _field(_phone, 'رقم الجوال',
                      Icons.phone_iphone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: _required),
                  const SizedBox(height: 10),
                  _field(_city, 'المدينة',
                      Icons.location_city_rounded,
                      validator: _required),
                  const SizedBox(height: 10),
                  _field(_address, 'العنوان التفصيلي',
                      Icons.home_outlined,
                      validator: _required),
                  const SizedBox(height: 10),
                  _field(_notes, 'ملاحظات (اختياري)',
                      Icons.note_alt_outlined),
                  const SizedBox(height: 22),
                  _sectionTitle('طريقة الدفع'),
                  const SizedBox(height: 10),
                  ..._walletOptions.map(_buildWalletTile),
                  if (_selected != null && _selected!.id != 'cash') ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: AppColors.goldDark),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'بعد فتح تطبيق المحفظة وإتمام التحويل، الصق رقم فاتورة الدفع هنا ثم اضغط إرسال عبر واتساب.',
                                  style: TextStyle(
                                      color: AppColors.goldDark, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _walletReceipt,
                            decoration: const InputDecoration(
                              hintText: 'رقم فاتورة الدفع من المحفظة',
                              prefixIcon: Icon(Icons.receipt_long_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  _sectionTitle('ملخص الطلب'),
                  const SizedBox(height: 10),
                  _summary(cart),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: _onSubmit,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('إرسال الطلب عبر واتساب'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'سيتم فتح واتساب مع رقم Rtouch لإرسال تفاصيل الفاتورة ورقم الدفع.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildWalletTile(PaymentOption opt) {
    final selected = _selected?.id == opt.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            setState(() => _selected = opt);
            if (opt.id != 'cash') {
              await _openWalletApp(opt);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.gold : const Color(0xFFEFE7D6),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: opt.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(opt.icon, color: opt.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt.title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(opt.subtitle,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: selected
                            ? AppColors.gold
                            : const Color(0xFFD8D2C0),
                        width: 2),
                    color: selected ? AppColors.gold : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openWalletApp(PaymentOption opt) async {
    // Try the URL scheme first, then Android intent fallback.
    bool launched = false;
    if (opt.scheme != null) {
      final uri = Uri.parse(opt.scheme!);
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
    if (!launched && opt.androidPackage != null) {
      final intentUri = Uri.parse(
          'intent://#Intent;package=${opt.androidPackage};end');
      try {
        launched = await launchUrl(intentUri,
            mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }
    }
    if (!launched && mounted) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Text(opt.title),
          content: const Text(
              'لم نتمكن من فتح تطبيق المحفظة تلقائيًا. يرجى فتح التطبيق يدويًا، إتمام عملية الدفع، ثم نسخ رقم فاتورة الدفع وإرفاقه هنا.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسنًا')),
          ],
        ),
      );
    }
  }

  Widget _summary(CartService cart) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFE7D6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('رقم الطلب',
                  style: TextStyle(color: AppColors.muted)),
              const Spacer(),
              SelectableText(_orderId,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldDark)),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _orderId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ رقم الطلب')),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
              ),
            ],
          ),
          const Divider(),
          ...cart.items.map(
            (it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${it.product.id} • ${it.product.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('×${it.quantity}',
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(width: 8),
                  Text(formatYer(it.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            children: [
              const Text('الإجمالي',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(formatYer(cart.total),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر طريقة الدفع أولًا')),
      );
      return;
    }

    final cart = CartService.instance;
    final lines = <String>[
      '🛍️ طلب جديد من تطبيق Rtouch',
      '━━━━━━━━━━━━━━━━━━',
      'رقم الطلب: $_orderId',
      'الاسم: ${_name.text.trim()}',
      'الجوال: ${_phone.text.trim()}',
      'المدينة: ${_city.text.trim()}',
      'العنوان: ${_address.text.trim()}',
      if (_notes.text.trim().isNotEmpty) 'ملاحظات: ${_notes.text.trim()}',
      '━━━━━━━━━━━━━━━━━━',
      'المنتجات:',
      ...cart.items.map((it) =>
          '• ${it.product.id} - ${it.product.name} ×${it.quantity} = ${formatYer(it.subtotal)}'),
      '━━━━━━━━━━━━━━━━━━',
      'الإجمالي: ${formatYer(cart.total)}',
      'طريقة الدفع: ${_selected!.title}',
      if (_selected!.id != 'cash' && _walletReceipt.text.trim().isNotEmpty)
        'رقم فاتورة الدفع (المحفظة): ${_walletReceipt.text.trim()}',
    ];
    final message = lines.join('\n');

    final url = Uri.parse(
        'https://wa.me/$kWhatsappNumber?text=${Uri.encodeComponent(message)}');

    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تعذّر فتح واتساب. تأكد من تثبيت التطبيق.')),
      );
      return;
    }
    if (mounted) {
      _showSuccess();
    }
  }

  void _showSuccess() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text('تم إرسال الطلب'),
          ],
        ),
        content: Text(
          'تم إرسال تفاصيل طلبك رقم $_orderId عبر واتساب. سيتواصل فريق Rtouch معك لتأكيد الطلب وترتيب التوصيل.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              CartService.instance.clear();
              Navigator.of(context)
                ..pop()
                ..pop()
                ..pop();
            },
            child: const Text('إلى الرئيسية'),
          ),
        ],
      ),
    );
  }
}
