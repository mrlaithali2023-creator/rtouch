import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  int get subtotal => product.priceYer * quantity;
}

class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get count => _items.values.fold(0, (s, it) => s + it.quantity);
  int get total => _items.values.fold(0, (s, it) => s + it.subtotal);
  bool get isEmpty => _items.isEmpty;

  void add(Product p, {int qty = 1}) {
    final existing = _items[p.id];
    if (existing == null) {
      _items[p.id] = CartItem(product: p, quantity: qty);
    } else {
      existing.quantity += qty;
    }
    notifyListeners();
  }

  void setQty(String id, int qty) {
    if (qty <= 0) {
      _items.remove(id);
    } else {
      _items[id]?.quantity = qty;
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

String formatYer(int amount) {
  final f = NumberFormat.decimalPattern('en');
  return '${f.format(amount)} ر.ي';
}
