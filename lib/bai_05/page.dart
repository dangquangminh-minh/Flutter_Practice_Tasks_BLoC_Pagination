import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';
import '../models/model_5.dart';
import '../repositories/repository_5.dart';

class Bai5 extends StatelessWidget {
  const Bai5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductBloc(ProductRepository())..add(FetchInitialData()),
      child: const ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductBloc>().add(LoadMoreProducts());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cửa hàng'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110), // Chiều cao cho Ô tìm kiếm + Bộ lọc
          child: _buildFilters(context),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          // lỗi trang đầu
          if (state.initialError.isNotEmpty && state.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.initialError),
                  ElevatedButton(
                    onPressed: () => context.read<ProductBloc>().add(FetchInitialData()),
                    child: const Text('Thử lại'),
                  )
                ],
              ),
            );
          }

          // Loading trang đầu
          if (state.isInitialLoading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Trống dữ liệu
          if (state.products.isEmpty) {
            return const Center(child: Text('Không tìm thấy sản phẩm nào.'));
          }

          // Danh sách sản phẩm 
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProductBloc>().add(RefreshProducts());
            },
            child: ListView.builder(
              // bonus: giữ nguyên chỗ scroll,lọc khi quay lại chỗ dssp
              key: const PageStorageKey('product_list'), 
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: state.products.length + (state.isLoadingMore || state.loadMoreError.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                // Hiển thị Card Sản phẩm
                if (index < state.products.length) {
                  return _buildProductCard(state.products[index]);
                }
                
                // Hiển thị phần dưới đáy (Loading More hoặc Error Load More)
                if (state.loadMoreError.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        state.loadMoreError, 
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // giao diện tìm kiếm và dropdown lọc
  Widget _buildFilters(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // Ô tìm kiếm
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  // update icon tìm kiếm vào cuối ô nhập liệu
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.blue),
                    onPressed: () {
                      // Ẩn bàn phím ảo xuống cho dễ nhìn danh sách
                      FocusManager.instance.primaryFocus?.unfocus();

                      // lấy từ khóa hiện tại trong controller để gọi api
                      final keyword = _searchController.text;
                      final currentQuery = context.read<ProductBloc>().state.query;
                      
                      context.read<ProductBloc>().add(
                        FilterChanged(currentQuery.copyWith(keyword: keyword)),
                      );
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {   // ấn enter thay vì icon
                  // Gọi sự kiện FilterChanged với keyword mới
                  final currentQuery = context.read<ProductBloc>().state.query;
                  context.read<ProductBloc>().add(
                    FilterChanged(currentQuery.copyWith(keyword: value)),
                  );
                },
              ),
              const SizedBox(height: 10),
              // Hàng chứa Dropdown Lọc danh mục và Sắp xếp
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Danh mục'),
                      value: state.query.category.isEmpty ? null : state.query.category,
                      items: [
                        const DropdownMenuItem(value: '', child: Text('Tất cả')),
                        ...state.categories.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        )),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          // Nếu chọn danh mục thì xóa text tìm kiếm để tránh xung đột API
                          _searchController.clear(); 
                          final currentQuery = context.read<ProductBloc>().state.query;
                          context.read<ProductBloc>().add(
                            FilterChanged(currentQuery.copyWith(
                              category: value, 
                              keyword: '', // Xóa keyword
                            )),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Sắp xếp giá'),
                      value: state.query.sortOrder.isEmpty ? null : state.query.sortOrder,
                      items: const [
                        DropdownMenuItem(value: '', child: Text('Mặc định')),
                        DropdownMenuItem(value: 'asc', child: Text('Giá Tăng dần')),
                        DropdownMenuItem(value: 'desc', child: Text('Giá Giảm dần')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          final currentQuery = context.read<ProductBloc>().state.query;
                          context.read<ProductBloc>().add(
                            FilterChanged(currentQuery.copyWith(sortOrder: value)),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // khối giao diện: card sp
  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          // Hình ảnh
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12), 
              bottomLeft: Radius.circular(12),
            ),
            child: Image.network(
              product.thumbnail,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                  const SizedBox(width: 100, height: 100, child: Icon(Icons.image_not_supported)),
            ),
          ),
          const SizedBox(width: 12),
          // Thông tin Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.category,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    color: Colors.redAccent, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}