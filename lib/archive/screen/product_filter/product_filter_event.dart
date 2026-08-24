import '../../models/product_filter_model.dart';

abstract class ProductEvent {}

// tải ds đầu tiên
class FetchInitialData extends ProductEvent {}

// event khi ng dùng tìm kiếm, lọc, sắp xếp
class FilterChanged extends ProductEvent {
  final QueryModel newQuery;
  FilterChanged(this.newQuery);
}

// event ng dùng kéo xuống cuối trang
class LoadMoreProducts extends ProductEvent {}

// event kéo lên để làm mới
class RefreshProducts extends ProductEvent {}