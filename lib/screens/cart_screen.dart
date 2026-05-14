import 'package:flutter/material.dart';

import '../services/cart_service.dart';
import '../theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سلة المشتريات')),
      body: AnimatedBuilder(
        animation: CartService.instance,
        builder: (_, _) {
          final cart = CartService.instance;
          if (cart.isEmpty) {
            return const _EmptyCart();
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final it = cart.items[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFE7D6)),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFBF7EE),
                                  Color(0xFFF1E9D4)
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(it.product.image,
                                fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    )),
                                const SizedBox(height: 4),
                                Text(it.product.id,
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    )),
                                const SizedBox(height: 6),
                                Text(formatYer(it.subtotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    )),
                              ],
                            ),
                          ),
                          _QtyControls(
                            qty: it.quantity,
                            onDec: () => cart.setQty(
                                it.product.id, it.quantity - 1),
                            onInc: () => cart.setQty(
                                it.product.id, it.quantity + 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _CheckoutBar(total: cart.total),
            ],
          );
        },
      ),
    );
  }
}

class _QtyControls extends StatelessWidget {
  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const _QtyControls({
    required this.qty,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1E2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.add_rounded, onInc),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Text('$qty',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          _btn(Icons.remove_rounded, onDec),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: AppColors.ink),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final int total;
  const _CheckoutBar({required this.total});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 18 + bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('الإجمالي',
                  style: TextStyle(color: AppColors.muted)),
              const Spacer(),
              Text(formatYer(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
              icon: const Icon(Icons.lock_outline_rounded),
              label: const Text('متابعة الدفع'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.15),
              ),
              child:
                  const Icon(Icons.shopping_bag_outlined, size: 56, color: AppColors.gold),
            ),
            const SizedBox(height: 18),
            const Text('سلتك فارغة',
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 6),
            const Text('ابدأ بإضافة منتجات Rtouch المميزة',
                style: TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
