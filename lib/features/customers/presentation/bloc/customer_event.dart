abstract class CustomerEvent {}

class FetchCustomersInitial extends CustomerEvent {}// tải ds khách hàng đầu tiên

class LoadMoreCustomers extends CustomerEvent {} // cuộn ds đên cuối trag

class SearchCustomersChanged extends CustomerEvent {// sk thông báo ng.dùng gõ tìm kiếm
  final String query;
  SearchCustomersChanged(this.query);
}


class GetCustomerDetailEvent extends CustomerEvent {
  final int id;
  GetCustomerDetailEvent(this.id);
}

class CustomerFilterRoleChanged extends CustomerEvent {//sk t.báo .n.dùng lọc theo vai trò
  final String role;
  CustomerFilterRoleChanged(this.role);
}

class CustomerSortOrderChanged extends CustomerEvent {// sk n.dùng thay đổi sắp xếp
  final String sortOrder;
  CustomerSortOrderChanged(this.sortOrder);
}

class AddCustomerRequested extends CustomerEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String image;
  AddCustomerRequested({
    required this.firstName, required this.lastName, required this.email, required this.role, required this.image
  });
}

class UpdateCustomerRequested extends CustomerEvent {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  UpdateCustomerRequested({
    required this.id, required this.firstName, required this.lastName, required this.email, required this.role
  });
}

class DeleteCustomerRequested extends CustomerEvent {
  final int id;
  DeleteCustomerRequested(this.id);
}