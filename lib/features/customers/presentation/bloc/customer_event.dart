abstract class CustomerEvent {}

class FetchCustomersInitial extends CustomerEvent {}// tải ds khách hàng đầu tiên

class LoadMoreCustomers extends CustomerEvent {} // cuộn ds đên cuối trag

class SearchCustomersChanged extends CustomerEvent {// sk thông báo ng.dùng gõ tìm kiếm
  final String query;
  SearchCustomersChanged(this.query);
}

class CustomerFilterRoleChanged extends CustomerEvent {//sk t.báo .n.dùng lọc theo vai trò
  final String role;
  CustomerFilterRoleChanged(this.role);
}

class CustomerSortOrderChanged extends CustomerEvent {// sk n.dùng thay đổi sắp xếp
  final String sortOrder;
  CustomerSortOrderChanged(this.sortOrder);
}