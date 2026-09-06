import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cache_retry_bloc.dart';
import '../bloc/cache_retry_event.dart';
import '../bloc/cache_retry_state.dart';
import '../../domain/models/cache_retry_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/data_sources/local_data_source.dart';
import '../../data/data_sources/remote_data_source.dart';

class Bai6 extends StatelessWidget {
  const Bai6({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductBloc6(
        ProductRepository6(
          localDataSource: LocalDataSource(),
          remoteDataSource: RemoteDataSource(),
        ),
      )..add(FetchInitialData6()),
      child: const ProductPage6(),
    );
  }
}

class ProductPage6 extends StatefulWidget {
  const ProductPage6({super.key});

  @override
  State<ProductPage6> createState() => _ProductPage6State();
}

class _ProductPage6State extends State<ProductPage6> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchProductController = TextEditingController();
  bool _isGridView = false;
  
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductBloc6>().add(LoadMoreProducts6());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Sản Phẩm'),
        elevation: 0,
      ),

      // nút dấu + để thêm sp
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(context), // gọi hàm mở dialog thêm mới
        child: const Icon(Icons.add),
      ),


      
      body: BlocConsumer<ProductBloc6, ProductState6>(
          listenWhen: (previous, current) {
              // chỉ listener khi có thay đổi
              return previous.loadMoreError != current.loadMoreError && current.loadMoreError.isNotEmpty;
            },

        listener: (context, state) {
          
           if (state.loadMoreError.isNotEmpty) {

           final realMessage = state.loadMoreError.split('|').first.trim();

           final isError = state.loadMoreError.toLowerCase().contains('lỗi') || 
                      state.loadMoreError.toLowerCase().contains('không');

            ScaffoldMessenger.of(context).hideCurrentSnackBar();          
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(realMessage), 
                backgroundColor: isError ? Colors.red : Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.initialError.isNotEmpty && state.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.initialError, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.read<ProductBloc6>().add(FetchInitialData6()),
                    child: const Text('Thử lại'),
                  )
                ],
              ),
            );
          }

          if (state.isInitialLoading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // thanh tìm kiếm , sắp xếp , lọc
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // thanh tìm kiếm
                        Expanded(
                          child: TextField(
                            controller: _searchProductController,
                            decoration:  InputDecoration(
                              hintText: 'Tìm kiếm sản phẩm...',
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _searchProductController,
                                builder: (context, value, child) {
                                  return value.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.cancel, size: 20, color: Colors.grey),
                                          onPressed: () {
                                            _searchProductController.clear(); // Xóa chữ trên UI
                                            context.read<ProductBloc6>().add(SearchQueryChanged('')); 
                                          },
                                        )
                                      : const SizedBox.shrink();
                                },
                              ),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (query) {
                              context.read<ProductBloc6>().add(SearchQueryChanged(query));
                            },
                          ),
                        ),
                        const SizedBox(width: 8),    

                        // nút chuyển đổi qua lại grid vs list
                        IconButton(
                          icon: Icon(
                            _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded, 
                            color: Colors.deepPurple.shade700,
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = !_isGridView; 
                            });
                          },
                        ),

                        // nút chọn sắp xếp ( tăng gaimr)
                        PopupMenuButton<String>(
                          icon: Icon(Icons.sort, color: Colors.deepPurple.shade700), 
                          onSelected: (order) {
                            context.read<ProductBloc6>().add(SortOrderChanged(order));
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'asc', child: Text('Giá: Thấp đến Cao')),
                            const PopupMenuItem(value: 'desc', child: Text('Giá: Cao đến Thấp')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // ô lọc
                    SizedBox(
                      height: 40,
                      child: FutureBuilder<List<String>>(
                        future: context.read<ProductBloc6>().repository.getCategories(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink(); 
                          }
                          final categories = snapshot.data!;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                final isSelected = state.selectedCategory == null || state.selectedCategory == ''; // ktra cả rỗng và null
                                
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ChoiceChip(
                                    label: const Text('Tất cả'),
                                    selected: isSelected,
                                    selectedColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade50,
                                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                                      side: BorderSide(
                                        color: isSelected 
                                            ? (isDark ? Colors.deepPurple.shade300 : Colors.deepPurple.shade200) 
                                            : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                      ),
                                      labelStyle: TextStyle(
                                        color: isSelected 
                                            ? (isDark ? Colors.deepPurple.shade200 : Colors.deepPurple.shade700) 
                                            : (isDark ? Colors.white70 : Colors.black87),
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    onSelected: (_) {
                                      context.read<ProductBloc6>().add(CategoryChanged('')); // thay null thành ''
                                    },
                                  ),
                                );
                              }

                              final category = categories[index - 1];
                              final isSelected = state.selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  selectedColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade50,
                                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                                    
                                    side: BorderSide(
                                      color: isSelected 
                                          ? (isDark ? Colors.deepPurple.shade300 : Colors.deepPurple.shade200) 
                                          : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                    ),
                                    
                                    labelStyle: TextStyle(
                                      color: isSelected 
                                          ? (isDark ? Colors.deepPurple.shade200 : Colors.deepPurple.shade700) 
                                          : (isDark ? Colors.white70 : Colors.black87),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  onSelected: (_) {
                                    context.read<ProductBloc6>().add(CategoryChanged(category));
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // banner t.báo offline
              if (state.isOffline)
                Container(
                  width: double.infinity,
                  color: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Bạn đang offline. Đang hiển thị dữ liệu lưu tạm.',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
              // dssp
              Expanded(
                child: RefreshIndicator( // vuốt để lm mới
                  onRefresh: () async { 
                    final bloc = context.read<ProductBloc6>();
                    bloc.add(RefreshProducts6()); 
                    await bloc.stream.firstWhere((s) => s.isInitialLoading == false);
                  },

                  // ktra rỗng               
                  child: state.products.isEmpty
                      ? ListView(                        
                          physics: const AlwaysScrollableScrollPhysics(), // ép ds luôn có thể cuộn ngay cả ds rỗng để pull to refresh
                          children: [
                            const SizedBox(height: 120), 
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.production_quantity_limits, size: 80, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                const Text(
                                  'Không tìm thấy sản phẩm',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Không có sản phẩm nào khớp với từ khóa bạn vừa nhập.\nVui lòng thử một từ khóa khác.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 24),
                                // nút xóa t.kiếm
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.blueAccent.shade100),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    // xóa chữ thanh t.kiếm
                                    _searchProductController.clear();
                                    // gọi bloc laod lại ds
                                    context.read<ProductBloc6>().add(SearchQueryChanged(''));
                                  },
                                  icon: const Icon(Icons.clear, color: Colors.blueAccent),
                                  label: const Text('Xóa tìm kiếm', style: TextStyle(color: Colors.blueAccent)),
                                ),
                              ],
                            ),
                          ],
                        )

                    // ktra đang ở grid hay list
                  : _isGridView
                      ? GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // h.thị 2 cột
                            childAspectRatio: 0.7, 
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: state.products.length + (state.isLoadingMore && !state.isOffline ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < state.products.length) {
                              return _buildProductGridCard(context, state.products[index]);
                            }
                            return const Center(child: CircularProgressIndicator());
                          },
                        )    
                  : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),


                    itemCount: state.products.length + (state.isLoadingMore && !state.isOffline ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < state.products.length) {
                        return _buildProductCard(context, state.products[index]);
                      }
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // card sp
  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          // hình ảnh sp
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
          
          // tiêu đề vs giá
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
                const SizedBox(height: 8),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // nút thả tim
          IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: product.isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              context.read<ProductBloc6>().add(ToggleFavorite6(product));
            },
          ),

          // menu sửa ,xóa sp
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // mở form sửa với dữ liệu cũ của sản phẩm này
                _showProductForm(context, productToEdit: product);
              } else if (value == 'delete') {
                // trc khi xóa sẽ hiện bảng xác nhận
                showDialog(
                  context: context,
                  builder: (confirmContext) => AlertDialog(
                    title: const Text('Xác nhận xóa'),
                    content: Text('Bạn có chắc muốn xóa "${product.title}" không?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(confirmContext), 
                        child: const Text('Hủy'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          // Bắn sự kiện xóa vào BLoC
                          context.read<ProductBloc6>().add(DeleteProductRequested(product.id));
                          Navigator.pop(confirmContext);
                        },
                        child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Sửa')),
              const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
            ],
          ),
          
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // hiển thị dialog khi thêm hay sửa
  void _showProductForm(BuildContext context, {Product? productToEdit}) {
    final titleController = TextEditingController(text: productToEdit?.title ?? '');
    final priceController = TextEditingController(text: productToEdit?.price.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(productToEdit == null ? 'Thêm sản phẩm mới' : 'Sửa sản phẩm'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator: (value) => value == null || value.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Giá (\$i)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập giá';
                  if (double.tryParse(value) == null) return 'Giá phải là số hợp lệ';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final title = titleController.text;
                final price = double.parse(priceController.text);

                if (productToEdit == null) {
                  // bắn sk lên bloc khi add sp
                  context.read<ProductBloc6>().add(AddProductRequested(
                    title: title, 
                    price: price, 
                    thumbnail: 'https://i.dummyjson.com/data/products/1/thumbnail.jpg',
                  ));
                } else {
                  // bắn sk khi update
                  context.read<ProductBloc6>().add(UpdateProductRequested(
                    id: productToEdit.id, 
                    title: title, 
                    price: price,
                  ));
                }
                Navigator.pop(dialogContext);
              }
            },
            child: Text(productToEdit == null ? 'Thêm' : 'Lưu'),
          ),
        ],
      ),
    );
  }

  // card sp của grid
  Widget _buildProductGridCard(BuildContext context, Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // hình ảnh
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.thumbnail,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          // tiêu đề vs giá
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1, // Dạng lưới hẹp nên chỉ cho hiện 1 dòng
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          //các nút tương tác
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                iconSize: 20,
                icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: product.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () => context.read<ProductBloc6>().add(ToggleFavorite6(product)),
              ),
              PopupMenuButton<String>(
                iconSize: 20,
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'edit') {
                    _showProductForm(context, productToEdit: product);
                  } else if (value == 'delete') {                  
                    context.read<ProductBloc6>().add(DeleteProductRequested(product.id));
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}