import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/active_cart_bloc/active_cart_bloc.dart';
import '../bloc/active_cart_bloc/active_cart_event.dart';
import '../bloc/active_cart_bloc/active_cart_state.dart';

class ActiveCartPage extends StatelessWidget {
  const ActiveCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
        centerTitle: true,
      ),
      body: BlocBuilder<ActiveCartBloc, ActiveCartState>(
        builder: (context, state) {
          // trạng thái chưa có gì hoặc giỏ hàng trống
          if (state is! ActiveCartUpdated || state.cart.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Giỏ hàng đang trống!', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tiếp tục mua sắm'),
                  )
                ],
              ),
            );
          }

          final cart = state.cart;

          return Column(
            children: [
              // dssp
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.products.length,
                  itemBuilder: (context, index) {
                    final item = cart.products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Tên và giá
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),


                            // tăng/giảm slg
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                  onPressed: () {
                                    context.read<ActiveCartBloc>().add(
                                      UpdateActiveCartQuantity(item.id, item.quantity - 1),
                                    );
                                  },
                                ),
                                Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                                  onPressed: () {
                                    context.read<ActiveCartBloc>().add(
                                      UpdateActiveCartQuantity(item.id, item.quantity + 1),
                                    );
                                  },
                                ),
                              ],
                            ),

                            // nút xóa sp
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                context.read<ActiveCartBloc>().add(RemoveProductFromCart(item.id));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // khung tổng tiền và thanh toán
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tổng thanh toán:', style: TextStyle(color: Colors.grey)),
                          Text(
                            '\$${cart.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), 
                          ),
                        ),
                        onPressed: () async {
                          // hiện tb đang xử lý
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đang xử lý thanh toán...'),
                              duration: Duration(seconds: 1),
                            ),
                          );

                          // giả lập chờ 2s
                          await Future.delayed(const Duration(seconds: 2));
                          if (context.mounted) {
                            
                            // xóa giỏ
                            context.read<ActiveCartBloc>().add(ClearActiveCartEvent());

                            // ok và quay lại
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thanh toán thành công!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context); 
                          }
                        },
                        child: const Text(
                          'Mua hàng',
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}