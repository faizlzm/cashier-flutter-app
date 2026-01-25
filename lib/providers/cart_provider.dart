import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashier_flutter_app/data/models/product_model.dart';
import 'package:cashier_flutter_app/data/models/cart_item_model.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(Product product) {
    final idx = state.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          i == idx
              ? CartItem(
                  product: state[i].product,
                  quantity: state[i].quantity + 1,
                )
              : state[i],
      ];
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeItem(String productId) =>
      state = state.where((i) => i.product.id != productId).toList();

  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    state = [
      for (final i in state)
        i.product.id == productId
            ? CartItem(product: i.product, quantity: qty)
            : i,
    ];
  }

  void clearCart() => state = [];

  double _taxRate = 11.0;

  void setTaxRate(double rate) {
    _taxRate = rate;
  }

  double get currentTaxRate => _taxRate;

  int get subtotal => state.fold(0, (s, i) => s + i.subtotal);
  int get tax => (subtotal * (_taxRate / 100)).round();
  int get total => subtotal + tax;
  int get itemCount => state.fold(0, (s, i) => s + i.quantity);
}
