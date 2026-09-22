import 'package:bai_01/features/carts/data/repositories/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';


class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc(this.repository) : super(CartInitial()) {
    on<LoadCartsByUserEvent>(_onLoadCarts);
  }

  Future<void> _onLoadCarts(LoadCartsByUserEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final carts = await repository.getCartsByUser(event.userId);
      emit(CartsLoaded(carts));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}