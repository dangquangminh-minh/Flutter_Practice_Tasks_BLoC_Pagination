import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Thay đổi import dưới đây theo đúng đường dẫn project của bạn
import 'package:bai_01/features/customers/presentation/bloc/customer_bloc.dart';
import 'package:bai_01/features/customers/presentation/bloc/customer_event.dart';
import 'package:bai_01/features/customers/presentation/bloc/customer_state.dart';
import 'package:bai_01/features/customers/data/repositories/customer_repository.dart';
import 'package:bai_01/features/customers/domain/models/customer_model.dart';

// 1. Tạo class Mock cho Repository
class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late MockCustomerRepository mockRepository;

  setUp(() {
    mockRepository = MockCustomerRepository();
  });

  group('CustomerBloc - Pagination Test', () {
    // Dữ liệu giả định
    final initialCustomers = [
      Customer(id: 1, firstName: 'A', lastName: 'Nguyen', email: '', phone: '', image: '', role: '', companyTitle: '', addressCity: ''),
    ];
    final moreCustomers = [
      Customer(id: 2, firstName: 'B', lastName: 'Tran', email: '', phone: '', image: '', role: '', companyTitle: '', addressCity: ''),
    ];

    blocTest<CustomerBloc, CustomerState>(
      'LoadMoreCustomers thành công, nối thêm danh sách mới vào danh sách cũ',
      // Bước 1: Khởi tạo Bloc với state ban đầu đã có 1 khách hàng
      build: () {
        when(() => mockRepository.getCustomers(1, 10, searchQuery: '', filterRole: '', sortOrder: ''))
            .thenAnswer((_) async => (data: moreCustomers, isOffline: false));
        return CustomerBloc(mockRepository);
      },
      seed: () => CustomerState(customers: initialCustomers, hasReachedMax: false),
      // Bước 2: Bắn event tải thêm
      act: (bloc) => bloc.add(LoadMoreCustomers()),
      // Bước 3: Kiểm tra trạng thái phát ra (Dùng Matcher để tránh lỗi so sánh Object)
      expect: () => [
        // Lần 1: isLoadMore = true
        isA<CustomerState>()
            .having((state) => state.isLoadingMore, 'isLoadingMore', true),
        // Lần 2: isLoadMore = false, danh sách được cộng dồn (1 + 1 = 2)
        isA<CustomerState>()
            .having((state) => state.isLoadingMore, 'isLoadingMore', false)
            .having((state) => state.customers.length, 'customers length', 2)
            .having((state) => state.hasReachedMax, 'hasReachedMax', false),
      ],
    );
  });
}