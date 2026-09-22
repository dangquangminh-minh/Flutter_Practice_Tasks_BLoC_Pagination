
import 'package:bai_01/features/carts/domain/models/cart_model.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartsLoaded extends CartState {
  final List<CartModel> carts;
  CartsLoaded(this.carts);
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}