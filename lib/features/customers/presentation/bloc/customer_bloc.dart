import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'customer_event.dart';
import 'customer_state.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
    final CustomerRepository repository;

    CustomerBloc(this.repository) : super(const CustomerState()) {
      on<FetchCustomersInitial>(_onFetchInitial); // lấy dl lần đầu
      on<LoadMoreCustomers>(_onLoadMore, transformer: droppable()); // xl phân trang 
      on<SearchCustomersChanged>(_onSearchQueryChanged, transformer: restartable()); // xl tìm kiếm

      on<CustomerFilterRoleChanged>(_onFilterRoleChanged);
      on<CustomerSortOrderChanged>(_onSortOrderChanged);
    }

    Future<void> _onFetchInitial(FetchCustomersInitial event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(isLoadingInitial: true, errorMessage: ''));
    try {
      final list = await repository.getCustomers( //lấy 10 item đầu tiên vs skip=0 limit=10
        0, 10, 

        searchQuery: state.searchQuery,
        filterRole: state.filterRole,
        sortOrder: state.sortOrder,
      );
      
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


    emit(state.copyWith(isLoadingMore: true));

    try {// lấy dl từ vị trí hiện tại
      final list = await repository.getCustomers(
        state.customers.length, 10, 
        searchQuery: state.searchQuery,
        filterRole: state.filterRole,
        sortOrder: state.sortOrder,
      );
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
}




