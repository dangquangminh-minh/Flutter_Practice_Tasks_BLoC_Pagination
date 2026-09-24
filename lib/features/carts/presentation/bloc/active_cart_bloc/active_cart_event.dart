abstract class ActiveCartEvent {}

class AddProductToCart extends ActiveCartEvent {
  final int productId;
  final String title;
  final double price;
  final double discountPercentage;

  AddProductToCart({
    required this.productId,
    required this.title,
    required this.price,
    required this.discountPercentage,
  });
}

class UpdateActiveCartQuantity extends ActiveCartEvent {
  final int productId;
  final int quantity;
  UpdateActiveCartQuantity(this.productId, this.quantity);
}

class RemoveProductFromCart extends ActiveCartEvent {
  final int productId;
  RemoveProductFromCart(this.productId);
}

class ClearActiveCartEvent extends ActiveCartEvent {}