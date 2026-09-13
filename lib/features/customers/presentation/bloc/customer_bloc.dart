import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'customer_event.dart';
import 'customer_state.dart';
import '../../data/repositories/customer_repository.dart';
import '../../domain/models/customer_model.dart';


class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
    final CustomerRepository repository;

    CustomerBloc(this.repository) : super(const CustomerState()) {
      on<FetchCustomersInitial>(_onFetchInitial); // lấy dl lần đầu
      on<LoadMoreCustomers>(_onLoadMore, transformer: droppable()); // xl phân trang 
      on<SearchCustomersChanged>(_onSearchQueryChanged, transformer: restartable()); // xl tìm kiếm

      on<CustomerFilterRoleChanged>(_onFilterRoleChanged,transformer: restartable(),);
      on<CustomerSortOrderChanged>(_onSortOrderChanged,transformer: restartable(),);
      on<GetCustomerDetailEvent>(_onGetCustomerDetail);

      on<AddCustomerRequested>(_onAddCustomer);
      on<UpdateCustomerRequested>(_onUpdateCustomer);
      on<DeleteCustomerRequested>(_onDeleteCustomer);
      
    }

    Future<void> _onFetchInitial(FetchCustomersInitial event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(isLoadingInitial: true, errorMessage: ''));
    try {
      final result = await repository.getCustomers( //lấy 10 item đầu tiên vs skip=0 limit=10
        0, 10, 

        searchQuery: state.searchQuery,
        filterRole: state.filterRole,
        sortOrder: state.sortOrder,
      );
      
      final list = result.data;
      emit(state.copyWith( // cập nhật state vs ds mới 

        isLoadingInitial: false,
        customers: list,
        hasReachedMax: list.length < 10, //ktra đã tải data hết từ server ch
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingInitial: false, errorMessage: 'Không thể kết nối tải danh sách.'));
    }
  }

  Future<void> _onLoadMore(LoadMoreCustomers event, Emitter<CustomerState> emit) async {
    if (state.isLoadingMore || state.hasReachedMax) return;


    emit(state.copyWith(isLoadingMore: true ,errorMessage: ''));

    try {// lấy dl từ vị trí hiện tại
      final result = await repository.getCustomers(
        state.customers.length, 10, 
        searchQuery: state.searchQuery,
        filterRole: state.filterRole,
        sortOrder: state.sortOrder,
      );

      final list = result.data;

      emit(state.copyWith(
        isLoadingMore: false,
        //nối vs mảng mới dô cuối mảng hiện tại
        customers: List.of(state.customers)..addAll(list),
        hasReachedMax: list.isEmpty,
      ));
    } catch (e) {

      emit(state.copyWith(isLoadingMore: false, errorMessage: 'Lỗi khi tải thêm.'));
    }
  }

    Future<void> _onSearchQueryChanged(SearchCustomersChanged event, Emitter<CustomerState> emit) async {
      emit(state.copyWith(searchQuery: event.query));
      await Future.delayed(const Duration(milliseconds: 500)); // debounce ngừng nửa s , khi họ gõ quá nửa 's' thì mới gọi api

      await _onFetchInitial(FetchCustomersInitial(), emit);// resett lại ds và lấy ds mới vs từ khóa mới
    }

    Future<void> _onFilterRoleChanged(CustomerFilterRoleChanged event, Emitter<CustomerState> emit) async {
      emit(state.copyWith(filterRole: event.role));
      await _onFetchInitial(FetchCustomersInitial(), emit); // reset lại ds
    }

    
    Future<void> _onSortOrderChanged(CustomerSortOrderChanged event, Emitter<CustomerState> emit) async {
      emit(state.copyWith(sortOrder: event.sortOrder));
      await _onFetchInitial(FetchCustomersInitial(), emit);
    }

    Future<void> _onGetCustomerDetail(GetCustomerDetailEvent event, Emitter<CustomerState> emit) async {
    // hiện loading tải dl
    emit(state.copyWith(isLoadingDetail: true, detailErrorMessage: ''));
    try {
      final customer = await repository.getCustomerDetail(event.id);
      // gọi api ok thì
      emit(state.copyWith(
        isLoadingDetail: false, // tắt
        customerDetail: customer, // nhét dl customer vào customerdetail để hiện dl
      ));
    } catch (e) {
      // bắt lỗi 
      emit(state.copyWith(
        isLoadingDetail: false,
        detailErrorMessage: 'Không thể tải chi tiết khách hàng.',
      ));
    }
  }

// hàm x.lý thêm
  Future<void> _onAddCustomer(AddCustomerRequested event, Emitter<CustomerState> emit) async {
    try {
      final newCustomer = await repository.addCustomer(
        firstName: event.firstName, 
        lastName: event.lastName, 
        email: event.email,
        role: event.role,
        image: event.image
      );
      // chèn k.hàng mới lên ui
      final updatedList = List<Customer>.from(state.customers)..insert(0, newCustomer);
      emit(state.copyWith(customers: updatedList, errorMessage: 'Thêm khách hàng thành công! | ${DateTime.now().millisecond}'));
    } catch (e) {
      //mất mạng thì sshow lỗi
      emit(state.copyWith(errorMessage: 'Lỗi mạng: Không thể thêm khách hàng! | ${DateTime.now().millisecond}'));
    }
  }

  // hàm xử lý update
  Future<void> _onUpdateCustomer(UpdateCustomerRequested event, Emitter<CustomerState> emit) async {
    final index = state.customers.indexWhere((c) => c.id == event.id);
    if (index == -1) return;

    final oldCustomer = state.customers[index];
    final updatedList = List<Customer>.from(state.customers);

    // update ui liền
    updatedList[index] = Customer(
      id: oldCustomer.id,
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      role: event.role,
      image: oldCustomer.image,
      phone: oldCustomer.phone,
      companyTitle: oldCustomer.companyTitle,
      addressCity: oldCustomer.addressCity,
    );
    emit(state.copyWith(customers: updatedList, errorMessage: ''));

    // gắn lên api
    try {
      await repository.updateCustomer(
        id: event.id, firstName: event.firstName, lastName: event.lastName, email: event.email, role: event.role
      );
      emit(state.copyWith(errorMessage: 'Cập nhật thành công!'));
    } catch (e) {
      updatedList[index] = oldCustomer;
      emit(state.copyWith(customers: updatedList, errorMessage: 'Lỗi mạng: Không thể cập nhật!'));
    }
  }

  // hàm x.l xóa
  Future<void> _onDeleteCustomer(DeleteCustomerRequested event, Emitter<CustomerState> emit) async {
    final index = state.customers.indexWhere((c) => c.id == event.id);
    if (index == -1) return;

    final deletedCustomer = state.customers[index];
    final updatedList = List<Customer>.from(state.customers)..removeAt(index);

    // xóa khỏi ui luôn
    emit(state.copyWith(customers: updatedList, errorMessage: ''));

    // xóa trên server
    try {
      await repository.deleteCustomer(event.id);
      emit(state.copyWith(errorMessage: 'Xóa thành công!'));
    } catch (e) {
      // rollback nếu xóa k đc
      updatedList.insert(index, deletedCustomer);
      emit(state.copyWith(customers: updatedList, errorMessage: 'Lỗi mạng: Không thể xóa!'));
    }
  }
}

