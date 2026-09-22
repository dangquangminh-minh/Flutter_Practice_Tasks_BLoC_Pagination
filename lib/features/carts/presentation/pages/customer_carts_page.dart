
import 'package:bai_01/features/carts/domain/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc/cart_bloc.dart';
import '../bloc/cart_bloc/cart_event.dart';
import '../bloc/cart_bloc/cart_state.dart';


class CustomerCartsPage extends StatelessWidget {
  final int userId;

  const CustomerCartsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của Khách'),
        backgroundColor: Colors.blueAccent,
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {

          // hiện snackbar khi đang update giỏ mà rớt mạng
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (state is CartError) {
            // lỗi khi load lần đầu
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CartBloc>().add(LoadCartsByUserEvent(userId)),
                    child: const Text('Thử lại'),
                  )
                ],
              ),
            );
          }

         if (state is CartsLoaded) {
            if (state.carts.isEmpty) {
              return const Center(child: Text('Khách hàng này chưa có giỏ hàng nào (Empty State)'));
            }

            //hiển thị dsgh
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.carts.length,
              itemBuilder: (context, index) {
                final cart = state.carts[index];
                return _buildCartCard(context, cart);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // widget hiển thị từng giỏ
  Widget _buildCartCard(BuildContext context, CartModel cart) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đơn hàng #${cart.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Chip(
                  label: Text('${cart.totalQuantity} items', style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.orange,
                ),
              ],
            ),
            const Divider(),
            // dssp trong giỏ
            ...cart.products.map((product) => _buildProductItem(context, cart.id, product)),
            const Divider(),
            // tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sau giảm giá:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                Text('\$${cart.discountedTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

// widget hiển thị từng sp
  Widget _buildProductItem(BuildContext context, int cartId, CartProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text('\$${product.price} / cái', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),       
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('x${product.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          
          SizedBox(
            width: 70,
            child: Text('\$${product.total.toStringAsFixed(2)}', 
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}