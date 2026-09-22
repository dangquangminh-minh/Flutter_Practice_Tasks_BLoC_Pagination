abstract class CartEvent {}

class LoadCartsByUserEvent extends CartEvent {
  final int userId;
  LoadCartsByUserEvent(this.userId);
}