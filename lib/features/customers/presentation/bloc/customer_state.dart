import '../../domain/models/customer_model.dart';

class CustomerState {
  final List<Customer> customers;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String errorMessage;
  final String searchQuery;
  final String filterRole; 
  final String sortOrder;

  const CustomerState({
    this.customers = const [],
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.searchQuery = '',
    this.filterRole = '',
    this.sortOrder = '',
  
  });

  CustomerState copyWith({
    List<Customer>? customers,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? errorMessage,
    String? searchQuery,
    String? filterRole,
    String? sortOrder,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterRole: filterRole ?? this.filterRole,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}