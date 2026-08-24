import '../../domain/models/cache_retry_model.dart';

abstract class ProductEvent6 {}

class FetchInitialData6 extends ProductEvent6 {}

class LoadMoreProducts6 extends ProductEvent6 {}


class ToggleFavorite6 extends ProductEvent6 { // nút tim khi ng dùng bấm tim trên ui
  final Product product;
  ToggleFavorite6(this.product);
}
class RefreshProducts6 extends ProductEvent6 {} // pull to refresh



// event tìm , lọc , s.xếp
class SearchQueryChanged extends ProductEvent6 {
  final String query;
  SearchQueryChanged(this.query);
}

class CategoryChanged extends ProductEvent6 {
  final String? category;
  CategoryChanged(this.category);
}

class SortOrderChanged extends ProductEvent6 {
  final String? sortOrder; // 'asc' hoặc 'desc'
  SortOrderChanged(this.sortOrder);
}




// event crud
class AddProductRequested extends ProductEvent6 {
  final String title;
  final double price;
  final String thumbnail;
  AddProductRequested({required this.title, required this.price, required this.thumbnail});
}

class UpdateProductRequested extends ProductEvent6 {
  final int id;
  final String title;
  final double price;
  UpdateProductRequested({required this.id, required this.title, required this.price});
}

class DeleteProductRequested extends ProductEvent6 {
  final int id;
  DeleteProductRequested(this.id);
}