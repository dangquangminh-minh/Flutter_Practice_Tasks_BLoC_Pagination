
import '../../../../carts/domain/models/cart_model.dart'; 

abstract class ActiveCartState {}

class ActiveCartInitial extends ActiveCartState {}

class ActiveCartUpdated extends ActiveCartState {
  final CartModel cart;
  ActiveCartUpdated(this.cart);
}