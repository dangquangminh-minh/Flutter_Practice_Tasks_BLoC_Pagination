import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';


import 'package:bai_01/features/products/presentation/bloc/cache_retry_bloc.dart'; // Chứa ProductBloc6
import 'package:bai_01/features/products/presentation/bloc/cache_retry_event.dart';
import 'package:bai_01/features/products/presentation/bloc/cache_retry_state.dart';
import 'package:bai_01/features/products/data/repositories/product_repository.dart';
import 'package:bai_01/features/products/domain/models/cache_retry_model.dart'; // Chứa class Product

class MockProductRepository extends Mock implements ProductRepository6 {}

void main() {
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
  });

  group('ProductBloc6 - CRUD Test', () {
    final mockProduct = Product(id: 1, title: 'Test Product', price: 10.0, thumbnail: '', isFavorite: false);
    final mockNewProduct = Product(id: 2, title: 'New Product', price: 20.0, thumbnail: '', isFavorite: false);

    blocTest<ProductBloc6, ProductState6>(
      'Thêm sản phẩm thành công (Add)',
      build: () {
        when(() => mockRepository.addProduct(
              title: 'New Product',
              price: 20.0,
              thumbnail: '',
            )).thenAnswer((_) async => mockNewProduct);
        return ProductBloc6(mockRepository);
      },
      seed: () => ProductState6(products: [mockProduct]), // State ban đầu có 1 sản phẩm
      act: (bloc) => bloc.add(AddProductRequested(title: 'New Product', price: 20.0, thumbnail: '')),
      expect: () => [
        // Sau khi thêm, độ dài danh sách phải là 2 và sản phẩm mới (id 2) được chèn lên đầu
        isA<ProductState6>()
            .having((state) => state.products.length, 'Số lượng SP', 2)
            .having((state) => state.products.first.id, 'ID sản phẩm mới', 2)
            .having((state) => state.loadMoreError.contains('Thêm sản phẩm thành công'), 'Thông báo thêm', true),
      ],
    );

    blocTest<ProductBloc6, ProductState6>(
      'Sửa sản phẩm thành công (Update)',
      build: () {
        when(() => mockRepository.updateProduct(id: 1, title: 'Updated Title', price: 15.0))
            .thenAnswer((_) async => mockNewProduct);
        return ProductBloc6(mockRepository);
      },
      seed: () => ProductState6(products: [mockProduct]),
      act: (bloc) => bloc.add(UpdateProductRequested(id: 1, title: 'Updated Title', price: 15.0)),
      expect: () => [
        // Hứng State 1: Lúc này BLoC đang cập nhật giao diện (chưa có thông báo)
        isA<ProductState6>(), 
        // Hứng State 2: Lúc này API chạy xong, thông báo thành công đã xuất hiện
        isA<ProductState6>()
            .having((state) => state.loadMoreError.contains('Cập nhật thành công'), 'Thông báo sửa', true),
      ],
    );

    blocTest<ProductBloc6, ProductState6>(
      'Xóa sản phẩm thành công (Delete)',
      build: () {
        when(() => mockRepository.deleteProduct(1)).thenAnswer((_) async => true);
        return ProductBloc6(mockRepository);
      },
      seed: () => ProductState6(products: [mockProduct]), // Ban đầu có 1 sản phẩm
      act: (bloc) => bloc.add(DeleteProductRequested(1)),
      expect: () => [
        // Lần 1: Optimistic Update (Xóa tạm khỏi giao diện)
        isA<ProductState6>()
            .having((state) => state.products.length, 'Số lượng sau khi xóa', 0),
        // Lần 2: Báo thành công
        isA<ProductState6>()
            .having((state) => state.loadMoreError.contains('Xóa sản phẩm thành công'), 'Thông báo xóa', true),
      ],
    );
  });
}