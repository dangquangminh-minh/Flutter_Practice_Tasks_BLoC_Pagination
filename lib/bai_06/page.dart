import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';
import '../models/model_6.dart';
import '../repositories/repository_6.dart';
import '../data_sources/local_data_source.dart';
import '../data_sources/remote_data_source.dart';

class Bai6 extends StatelessWidget {
  const Bai6({Key? key}) : super(key: key);

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
  const ProductPage6({Key? key}) : super(key: key);

  @override
  State<ProductPage6> createState() => _ProductPage6State();
}

class _ProductPage6State extends State<ProductPage6> {
  final ScrollController _scrollController = ScrollController();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài 6 - Production'),
        elevation: 0,
      ),
      //sd blocconsumer vừa vẽ ui (build) vừa lắng nghe sự kiện ngầm (listener) 
      body: BlocConsumer<ProductBloc6, ProductState6>(
        listener: (context, state) {
          // Bắt lỗi Rollback thả tim từ BLoC để hiện thông báo (SnackBar)
          if (state.loadMoreError.contains('thả tim')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.loadMoreError),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          // lỗi mạng lần đầu (Không có cache)
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

          //Đang tải lần đầu
          if (state.isInitialLoading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
             
              //  offline (isoffline = true)
             
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
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProductBloc6>().add(FetchInitialData6());
                  },
                  child: ListView.builder(
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

  // Card sản phẩm
  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      elevation: 2,
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
          // Thông tin sản phẩm
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
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}