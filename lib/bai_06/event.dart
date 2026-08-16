import '../models/model_6.dart';

abstract class ProductEvent6 {}

class FetchInitialData6 extends ProductEvent6 {}

class LoadMoreProducts6 extends ProductEvent6 {}

// bonus: khi khách hàng bấm nút tim trên ui
class ToggleFavorite6 extends ProductEvent6 {
  final Product product;
  ToggleFavorite6(this.product);
}