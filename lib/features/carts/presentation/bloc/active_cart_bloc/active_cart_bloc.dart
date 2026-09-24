import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart'; //sửa debugprint
import 'package:bloc_concurrency/bloc_concurrency.dart'; // chặn spam click nút
import 'active_cart_event.dart';
import 'active_cart_state.dart';
import '../../../../carts/domain/models/cart_model.dart'; 

import '../../../../carts/data/repositories/cart_repository.dart'; 

class ActiveCartBloc extends Bloc<ActiveCartEvent, ActiveCartState> {

  final CartRepository repository;

  // khởi tạo giỏ hàng
  CartModel _currentCart = CartModel(
    id: 1,
    products: [], total: 0, discountedTotal: 0, userId: 1, totalProducts: 0, totalQuantity: 0,
  );


  ActiveCartBloc(this.repository) : super(ActiveCartInitial()) {
    on<AddProductToCart>(
      _onAddToCart,
      transformer: droppable(), //chặn spam nút
    );
    on<UpdateActiveCartQuantity>(
      _onUpdateQuantity,
      transformer: droppable(), 
    );
    on<RemoveProductFromCart>(
      _onRemoveProduct,
      transformer: droppable(), 
    );

    on<ClearActiveCartEvent>(
      _onClearCart,
      transformer: droppable(),
    );
  }


  Future<void> _onAddToCart(AddProductToCart event, Emitter<ActiveCartState> emit) async {
    final products = List<CartProductModel>.from(_currentCart.products);
    final index = products.indexWhere((p) => p.id == event.productId);

    if (index != -1) {
      // đã có thì tăng slg
      final p = products[index];
      products[index] = p.copyWith(quantity: p.quantity + 1);
    } else {
      // chưa có thì thêm mới
      products.add(CartProductModel(
        id: event.productId, title: event.title, price: event.price,
        quantity: 1, total: 0, discountPercentage: event.discountPercentage, discountedTotal: 0,
      ));
    }
    
    //cập nhật ui liền
    _recalculateAndEmit(products, emit);
    // bắn api ngầm
    try {
      await repository.addProductToCartApi(1, [
        {'id': event.productId, 'quantity': 1}
      ]);
    } catch (e) {
      debugPrint('Lỗi đồng bộ API Add Cart: $e');
    }
  }

  Future<void> _onUpdateQuantity(UpdateActiveCartQuantity event, Emitter<ActiveCartState> emit) async {
    final products = List<CartProductModel>.from(_currentCart.products);
    final index = products.indexWhere((p) => p.id == event.productId);

    if (index != -1) {
      if (event.quantity <= 0) {
        products.removeAt(index);
      } else {
        products[index] = products[index].copyWith(quantity: event.quantity);
      }
      
      _recalculateAndEmit(products, emit);

      try {
        await repository.updateCartApi(_currentCart.id, [
          {'id': event.productId, 'quantity': event.quantity}
        ]);
      } catch (e) {
        debugPrint('Lỗi đồng bộ API Update Cart: $e');
      }
    }
  }

  Future<void> _onRemoveProduct(RemoveProductFromCart event, Emitter<ActiveCartState> emit) async {
    final products = List<CartProductModel>.from(_currentCart.products);
    products.removeWhere((p) => p.id == event.productId);
    
    _recalculateAndEmit(products, emit);

    try {
      final updatedProducts = products.map((p) => {'id': p.id, 'quantity': p.quantity}).toList();
      await repository.updateCartApi(_currentCart.id, updatedProducts);
    } catch (e) {
      debugPrint('Lỗi đồng bộ API Remove Cart: $e');
    }
  }

  Future<void> _onClearCart(ClearActiveCartEvent event, Emitter<ActiveCartState> emit) async {
    _recalculateAndEmit([], emit);
  }

  // tính tổng tiền và tổng slg
  void _recalculateAndEmit(List<CartProductModel> products, Emitter<ActiveCartState> emit) {
    double total = 0;
    double discountedTotal = 0;
    int totalQuantity = 0;

    final updatedProducts = products.map((p) {
      final itemTotal = p.price * p.quantity;
      final itemDiscounted = itemTotal - (itemTotal * (p.discountPercentage / 100));
      
      total += itemTotal;
      discountedTotal += itemDiscounted;
      totalQuantity += p.quantity;

      return p.copyWith(total: itemTotal, discountedTotal: itemDiscounted);
    }).toList();

    _currentCart = _currentCart.copyWith(
      products: updatedProducts,
      total: total,
      discountedTotal: discountedTotal,
      totalQuantity: totalQuantity,
      totalProducts: updatedProducts.length,
    );

    emit(ActiveCartUpdated(_currentCart));
  }

  
}